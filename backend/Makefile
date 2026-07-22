.PHONY: help run build test lint migrate-up migrate-down docker-up docker-down

APP_NAME=flex-api

help:
	@echo "Usage:"
	@echo "  make run           - Run the API server"
	@echo "  make build         - Build binary"
	@echo "  make test          - Run tests"
	@echo "  make lint          - Run linter"
	@echo "  make migrate-up    - Run database migrations"
	@echo "  make migrate-down  - Rollback migrations"
	@echo "  make docker-up     - Start all services (Docker)"
	@echo "  make docker-down   - Stop all services"

run:
	go run ./cmd/server

build:
	go build -ldflags="-s -w" -o bin/$(APP_NAME) ./cmd/server

test:
	go test -v -race -count=1 ./...

lint:
	golangci-lint run ./...

migrate-up:
	go run ./cmd/migrate up

migrate-down:
	go run ./cmd/migrate down

docker-up:
	docker-compose up -d --build

docker-down:
	docker-compose down -v
