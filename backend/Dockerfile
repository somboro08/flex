FROM golang:1.22-alpine AS builder

RUN apk add --no-cache git ca-certificates tzdata

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-s -w" \
    -o /app/bin/server ./cmd/server

FROM alpine:3.19

RUN apk add --no-cache ca-certificates tzdata curl

WORKDIR /app

COPY --from=builder /app/bin/server .
COPY --from=builder /app/migrations ./migrations

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/api/v1/health || exit 1

ENTRYPOINT ["./server"]
