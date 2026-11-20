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

## Configuration des environnements et des URL

Le backend lit les variables d'environnement (ou le fichier `.env` local). Les URL ne doivent jamais être codées en dur dans les services.

Variables principales :

- `API_PUBLIC_URL` : URL publique de cette API. En production Render, utiliser `https://flex-1wlr.onrender.com`.
- `SERVER_HOST` / `SERVER_PORT` : adresse et port d'écoute internes du processus.
- `CORS_ALLOWED_ORIGINS` : liste séparée par des virgules des origines frontend autorisées, sans chemin (ex. `https://app.example.com,https://admin.example.com`).
- `DATABASE_URL`, `REDIS_URL` : adresses des services de données.
- `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD` : serveur d'e-mail.

En production, `CORS_ALLOWED_ORIGINS` est obligatoire et doit contenir les domaines frontend exacts (par exemple `https://ton-frontend.com`, sans chemin ni slash final). Pour Render, définir `API_PUBLIC_URL=https://flex-1wlr.onrender.com` dans les variables d'environnement du service backend. Le backend refuse désormais de démarrer avec une liste CORS vide en production ; il n'ouvre jamais automatiquement CORS à toutes les origines.

Pour Docker Compose, copier `.env.example` vers `.env`, puis renseigner les valeurs. Les secrets JWT et les origines CORS sont obligatoires. Les variables définies dans l'environnement de la plateforme de déploiement peuvent remplacer celles du fichier local.

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

Pour lancer le frontend Flutter avec l'API locale :

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

Sur un émulateur Android, utiliser `http://10.0.2.2:8080/api/v1`. Pour une build de production sur l'API Render Flex, fournir l'URL HTTPS publique :

```bash
flutter build apk --dart-define=API_BASE_URL=https://flex-1wlr.onrender.com/api/v1
```

La valeur est centralisée dans `lib/config/api_config.dart` et le client Dio partagé dans `lib/services/api_client.dart`. Ne pas créer une URL différente dans chaque service.


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
