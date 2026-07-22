package main

import (
	"fmt"
	"os"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/somboro08/flex-api/internal/config"
)

func main() {
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})

	cfg, err := config.Load()
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to load configuration")
	}

	if len(os.Args) < 2 {
		fmt.Println("Usage: go run ./cmd/migrate [up|down]")
		os.Exit(1)
	}

	command := os.Args[1]

	m, err := migrate.New(
		"file://migrations",
		cfg.Database.URL,
	)
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to create migration instance")
	}

	switch command {
	case "up":
		if err := m.Up(); err != nil && err != migrate.ErrNoChange {
			log.Fatal().Err(err).Msg("Migration up failed")
		}
		log.Info().Msg("Migration up completed")
	case "down":
		if err := m.Down(); err != nil && err != migrate.ErrNoChange {
			log.Fatal().Err(err).Msg("Migration down failed")
		}
		log.Info().Msg("Migration down completed")
	default:
		fmt.Println("Usage: go run ./cmd/migrate [up|down]")
		os.Exit(1)
	}
}
