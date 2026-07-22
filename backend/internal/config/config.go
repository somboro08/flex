package config

import (
	"fmt"
	"time"

	"github.com/rs/zerolog"
	"github.com/spf13/viper"
)

type Config struct {
	Server   ServerConfig
	Database DatabaseConfig
	Redis    RedisConfig
	JWT      JWTConfig
	Email    EmailConfig
	SMS      SMSConfig
	RateLimit RateLimitConfig
	CORS     CORSConfig
	Momo     MomoConfig
}

type ServerConfig struct {
	Port        string
	Host        string
	Environment string
	LogLevel    string
}

type DatabaseConfig struct {
	URL             string
	MaxOpenConns    int
	MaxIdleConns    int
	ConnMaxLifetime time.Duration
}

type RedisConfig struct {
	URL      string
	Password string
}

type JWTConfig struct {
	AccessSecret   string
	RefreshSecret  string
	AccessExpiry   time.Duration
	RefreshExpiry  time.Duration
	Issuer         string
}

type EmailConfig struct {
	SMTPHost     string
	SMTPPort     int
	Username     string
	Password     string
	FromAddress  string
}

type SMSConfig struct {
	TwilioAccountSID string
	TwilioAuthToken  string
	TwilioPhone      string
}

type RateLimitConfig struct {
	Requests int
	Window   time.Duration
}

type CORSConfig struct {
	AllowedOrigins []string
}

type MomoConfig struct {
	APIKey      string
	APISecret   string
	Environment string
}

func Load() (*Config, error) {
	v := viper.New()

	v.SetConfigFile(".env")
	v.SetConfigType("env")
	v.AddConfigPath(".")
	v.AddConfigPath("..")

	v.AutomaticEnv()

	_ = v.ReadInConfig()

	cfg := &Config{
		Server: ServerConfig{
			Port:        v.GetString("SERVER_PORT"),
			Host:        v.GetString("SERVER_HOST"),
			Environment: v.GetString("ENVIRONMENT"),
			LogLevel:    v.GetString("LOG_LEVEL"),
		},
		Database: DatabaseConfig{
			URL:          v.GetString("DATABASE_URL"),
			MaxOpenConns: v.GetInt("DATABASE_MAX_OPEN_CONNS"),
			MaxIdleConns: v.GetInt("DATABASE_MAX_IDLE_CONNS"),
		},
		Redis: RedisConfig{
			URL:      v.GetString("REDIS_URL"),
			Password: v.GetString("REDIS_PASSWORD"),
		},
		JWT: parseJWTConfig(v),
		Email: EmailConfig{
			SMTPHost:    v.GetString("SMTP_HOST"),
			SMTPPort:    v.GetInt("SMTP_PORT"),
			Username:    v.GetString("SMTP_USERNAME"),
			Password:    v.GetString("SMTP_PASSWORD"),
			FromAddress: v.GetString("EMAIL_FROM"),
		},
		SMS: SMSConfig{
			TwilioAccountSID: v.GetString("TWILIO_ACCOUNT_SID"),
			TwilioAuthToken:  v.GetString("TWILIO_AUTH_TOKEN"),
			TwilioPhone:      v.GetString("TWILIO_PHONE_NUMBER"),
		},
		RateLimit: RateLimitConfig{
			Requests: v.GetInt("RATE_LIMIT_REQUESTS"),
			Window:   time.Duration(v.GetInt("RATE_LIMIT_WINDOW")) * time.Second,
		},
		CORS: CORSConfig{
			AllowedOrigins: v.GetStringSlice("CORS_ALLOWED_ORIGINS"),
		},
		Momo: MomoConfig{
			APIKey:      v.GetString("MTN_MOMO_API_KEY"),
			APISecret:   v.GetString("MTN_MOMO_API_SECRET"),
			Environment: v.GetString("MTN_MOMO_ENVIRONMENT"),
		},
	}

	if err := cfg.validate(); err != nil {
		return nil, fmt.Errorf("invalid config: %w", err)
	}

	return cfg, nil
}

func parseJWTConfig(v *viper.Viper) JWTConfig {
	accessExpiry, err := time.ParseDuration(v.GetString("JWT_ACCESS_EXPIRY"))
	if err != nil {
		accessExpiry = 15 * time.Minute
	}
	refreshExpiry, err := time.ParseDuration(v.GetString("JWT_REFRESH_EXPIRY"))
	if err != nil {
		refreshExpiry = 7 * 24 * time.Hour
	}
	return JWTConfig{
		AccessSecret:  v.GetString("JWT_ACCESS_SECRET"),
		RefreshSecret: v.GetString("JWT_REFRESH_SECRET"),
		AccessExpiry:  accessExpiry,
		RefreshExpiry: refreshExpiry,
		Issuer:        v.GetString("JWT_ISSUER"),
	}
}

func (cfg *Config) validate() error {
	if cfg.Server.Port == "" {
		cfg.Server.Port = "8080"
	}
	if cfg.Server.Host == "" {
		cfg.Server.Host = "0.0.0.0"
	}
	if cfg.Server.Environment == "" {
		cfg.Server.Environment = "development"
	}
	if cfg.Server.LogLevel == "" {
		cfg.Server.LogLevel = "debug"
	}
	if cfg.Database.URL == "" {
		return fmt.Errorf("DATABASE_URL is required")
	}
	if cfg.Database.MaxOpenConns == 0 {
		cfg.Database.MaxOpenConns = 25
	}
	if cfg.Database.MaxIdleConns == 0 {
		cfg.Database.MaxIdleConns = 10
	}
	if cfg.JWT.AccessSecret == "" {
		return fmt.Errorf("JWT_ACCESS_SECRET is required")
	}
	if cfg.JWT.RefreshSecret == "" {
		return fmt.Errorf("JWT_REFRESH_SECRET is required")
	}
	if cfg.RateLimit.Requests == 0 {
		cfg.RateLimit.Requests = 100
	}
	if cfg.RateLimit.Window == 0 {
		cfg.RateLimit.Window = 60 * time.Second
	}
	return nil
}

func (cfg *Config) IsProduction() bool {
	return cfg.Server.Environment == "production"
}

func (cfg *Config) LogLevelZero() zerolog.Level {
	switch cfg.Server.LogLevel {
	case "debug":
		return zerolog.DebugLevel
	case "info":
		return zerolog.InfoLevel
	case "warn":
		return zerolog.WarnLevel
	case "error":
		return zerolog.ErrorLevel
	default:
		return zerolog.InfoLevel
	}
}
