package database

import (
	"fmt"
	"time"

	"github.com/rs/zerolog/log"
	"github.com/somboro08/flex-api/internal/config"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	gormlogger "gorm.io/gorm/logger"
)

func NewPostgres(cfg config.DatabaseConfig) (*gorm.DB, error) {
	db, err := gorm.Open(postgres.Open(cfg.URL), &gorm.Config{
		Logger: gormlogger.Default.LogMode(gormlogger.Warn),
		NowFunc: func() time.Time {
			return time.Now().UTC()
		},
		SkipDefaultTransaction: true,
		PrepareStmt:            true,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to connect to postgres: %w", err)
	}

	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("failed to get underlying sql.DB: %w", err)
	}

	sqlDB.SetMaxOpenConns(cfg.MaxOpenConns)
	sqlDB.SetMaxIdleConns(cfg.MaxIdleConns)
	sqlDB.SetConnMaxLifetime(cfg.ConnMaxLifetime * time.Second)

	if err := sqlDB.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping postgres: %w", err)
	}

	log.Info().
		Int("max_open_conns", cfg.MaxOpenConns).
		Int("max_idle_conns", cfg.MaxIdleConns).
		Msg("postgres connected")

	return db, nil
}
