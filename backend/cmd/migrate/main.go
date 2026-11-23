package main

import (
	"fmt"
	"os"
	"strconv"

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
		fmt.Println("Usage: go run ./cmd/migrate [up|down|force <version>|check]")
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
	case "force":
		if len(os.Args) < 3 {
			fmt.Println("Usage: go run ./cmd/migrate force <version>")
			os.Exit(1)
		}
		version, err := strconv.Atoi(os.Args[2])
		if err != nil {
			log.Fatal().Err(err).Msg("Invalid version")
		}
		if err := m.Force(version); err != nil {
			log.Fatal().Err(err).Msg("Force version failed")
		}
		log.Info().Int("version", version).Msg("Version forced")
	case "check":
		version, dirty, err := m.Version()
		if err != nil {
			fmt.Printf("state: none (%v)\n", err)
			os.Exit(0)
		}
		fmt.Printf("state: version=%d dirty=%v\n", version, dirty)
	default:
		fmt.Println("Usage: go run ./cmd/migrate [up|down|force <version>|check]")
		os.Exit(1)
	}
}
