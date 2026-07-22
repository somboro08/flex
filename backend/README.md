# Flex API — Backend

API REST robuste en Go avec Gin pour l'application Flex.

## Stack

- **Go 1.22+** avec **Gin** (HTTP)
- **PostgreSQL 16** avec **GORM** (ORM)
- **Redis 7** (rate limiting, cache, sessions)
- **JWT** (access + refresh tokens)
- **Docker** + docker-compose

## Prérequis

- Go 1.22+
- PostgreSQL 16+
- Redis 7+
- Docker (optionnel)

## Installation

```bash
# Cloner
cd backend

# Copier la config
cp .env.example .env
# Éditer .env avec vos valeurs

# Installer les dépendances
go mod tidy

# Lancer les migrations
go run ./cmd/migrate up

# Démarrer le serveur
go run ./cmd/server
```

## Avec Docker

```bash
docker-compose up -d --build
```

## Structure

```
backend/
├── cmd/
│   ├── server/        # Point d'entrée API
│   └── migrate/       # CLI de migration
├── internal/
│   ├── config/        # Configuration (viper)
│   ├── database/      # PostgreSQL + Redis
│   ├── models/        # GORM models
│   ├── repository/    # Accès données
│   ├── services/      # Logique métier
│   ├── handlers/      # Contrôleurs HTTP
│   └── middleware/    # Auth, rate-limit, CORS
├── pkg/
│   ├── jwt/           # JWT manager
│   ├── response/      # Réponses standardisées
│   └── validator/     # Validation personnalisée
├── migrations/        # SQL migrations
├── Dockerfile
├── docker-compose.yml
└── Makefile
```

## Authentification

- **Register** — Inscription avec téléphone + mot de passe fort
- **Login** — Connexion avec rate limiting (5 tentatives → verrouillage 15min)
- **JWT** — Access token (15min) + Refresh token (7 jours)
- **OTP** — Code à 6 chiffres pour vérification téléphone/email
- **Password reset** — via OTP téléphonique
- **RBAC** — 3 rôles: voyageur, hote, agent

## API Endpoints

| Méthode | Endpoint | Auth | Description |
|---------|----------|------|-------------|
| GET | /api/v1/health | - | Health check |
| GET | /api/v1/readiness | - | Readiness check |
| POST | /api/v1/auth/register | - | Inscription |
| POST | /api/v1/auth/login | - | Connexion |
| POST | /api/v1/auth/refresh | - | Rafraîchir token |
| POST | /api/v1/auth/otp/send | - | Envoyer OTP |
| POST | /api/v1/auth/otp/verify | - | Vérifier OTP |
| POST | /api/v1/auth/password/reset | - | Réinitialiser mot de passe |
| GET | /api/v1/me | Oui | Mon profil |
| POST | /api/v1/auth/logout | Oui | Déconnexion |
| PUT | /api/v1/auth/password | Oui | Changer mot de passe |
| GET | /api/v1/listings | - | Liste des logements |
| GET | /api/v1/listings/:id | - | Détail logement |
| POST | /api/v1/listings | Oui (hote) | Créer logement |
| PUT | /api/v1/listings/:id | Oui (hote) | Modifier logement |
| DELETE | /api/v1/listings/:id | Oui (hote) | Supprimer logement |
| GET | /api/v1/listings/mine | Oui (hote) | Mes logements |
| POST | /api/v1/bookings | Oui | Créer réservation |
| GET | /api/v1/bookings | Oui | Mes réservations |
| GET | /api/v1/bookings/:id | Oui | Détail réservation |
| POST | /api/v1/bookings/:id/cancel | Oui | Annuler |
| POST | /api/v1/bookings/:id/confirm | Oui (hote) | Confirmer |
