package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/somboro08/flex-api/internal/config"
	"github.com/somboro08/flex-api/internal/database"
	"github.com/somboro08/flex-api/internal/handlers"
)

func main() {
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})

	cfg, err := config.Load()
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to load configuration")
	}

	zerolog.SetGlobalLevel(cfg.LogLevelZero())

	log.Info().Str("environment", cfg.Server.Environment).Msg("Flex API starting")

	db, err := database.NewPostgres(cfg.Database)
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to connect to database")
	}

	rdb, err := database.NewRedis(cfg.Redis)
	if err != nil {
		log.Warn().Err(err).Msg("Redis not available, continuing without it")
		rdb = nil
	}

	h := handlers.NewHandlers(db, rdb, cfg)
	router := handlers.SetupRouter(h, cfg, db, rdb)

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		addr := fmt.Sprintf("%s:%s", cfg.Server.Host, cfg.Server.Port)
		log.Info().Str("address", addr).Msg("Server listening")
		if err := router.Run(addr); err != nil {
			log.Fatal().Err(err).Msg("Server failed to start")
		}
	}()

	<-quit
	log.Info().Msg("Shutting down server...")
}
