-- ============================================
-- Flex API — Migration initiale
-- ============================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- ENUMS
-- ============================================
CREATE TYPE user_role AS ENUM ('voyageur', 'hote', 'agent');
CREATE TYPE identity_status AS ENUM ('none', 'pending', 'verified', 'rejected');
CREATE TYPE certification_status AS ENUM ('pending', 'certified', 'rejected');
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'checked_in', 'completed', 'cancelled');
CREATE TYPE payment_method AS ENUM ('mtn_momo', 'moov_money', 'wave', 'credit_card', 'cash', 'cinetpay');
CREATE TYPE payment_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'refunded');

-- ============================================
-- USERS
-- ============================================
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom             VARCHAR(100) NOT NULL,
    prenom          VARCHAR(100) NOT NULL,
    telephone       VARCHAR(20) UNIQUE NOT NULL,
    email           VARCHAR(255) UNIQUE,
    password_hash   VARCHAR(255),
    photo_url       TEXT,
    role            user_role NOT NULL DEFAULT 'voyageur',
    is_verified     BOOLEAN DEFAULT FALSE,
    is_onboarded    BOOLEAN DEFAULT FALSE,
    is_active       BOOLEAN DEFAULT TRUE,
    verification_status identity_status NOT NULL DEFAULT 'none',
    id_card_url     TEXT,
    birth_certificate_url TEXT,
    email_verified_at TIMESTAMPTZ,
    phone_verified_at TIMESTAMPTZ,
    last_login_at   TIMESTAMPTZ,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until    TIMESTAMPTZ,
    refresh_token   TEXT,
    favorites       UUID[] DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_users_telephone ON users(telephone) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_role ON users(role);

-- ============================================
-- SESSIONS / REFRESH TOKENS
-- ============================================
CREATE TABLE sessions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    refresh_token   VARCHAR(512) NOT NULL,
    device_info     TEXT,
    ip_address      VARCHAR(45),
    user_agent      TEXT,
    is_revoked      BOOLEAN DEFAULT FALSE,
    expires_at      TIMESTAMPTZ NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    revoked_at      TIMESTAMPTZ
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_refresh_token ON sessions(refresh_token);

-- ============================================
-- OTP CODES
-- ============================================
CREATE TABLE otp_codes (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    identifier      VARCHAR(255) NOT NULL,   -- phone or email
    code            VARCHAR(6) NOT NULL,
    purpose         VARCHAR(50) NOT NULL,    -- 'phone_verification', 'email_verification', 'password_reset', 'login'
    attempts        INTEGER DEFAULT 0,
    max_attempts    INTEGER DEFAULT 5,
    is_used         BOOLEAN DEFAULT FALSE,
    expires_at      TIMESTAMPTZ NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_otp_identifier ON otp_codes(identifier, purpose);

-- ============================================
-- LISTINGS
-- ============================================
CREATE TABLE listings (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hote_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    titre           VARCHAR(200) NOT NULL,
    description     TEXT NOT NULL,
    ville           VARCHAR(100) NOT NULL,
    quartier        VARCHAR(100) NOT NULL,
    adresse         TEXT NOT NULL,
    latitude        DECIMAL(10, 7) NOT NULL,
    longitude       DECIMAL(10, 7) NOT NULL,
    prix_par_nuit   DECIMAL(10, 2) NOT NULL CHECK (prix_par_nuit > 0),
    nombre_chambres INTEGER DEFAULT 1,
    photos          TEXT[] DEFAULT '{}',
    equipements     TEXT[] DEFAULT '{}',
    certification   certification_status NOT NULL DEFAULT 'pending',
    note            DECIMAL(2, 1) DEFAULT 0.0 CHECK (note >= 0 AND note <= 5),
    nombre_avis     INTEGER DEFAULT 0,
    is_disponible   BOOLEAN DEFAULT TRUE,
    views_count     INTEGER DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_listings_ville ON listings(ville) WHERE deleted_at IS NULL;
CREATE INDEX idx_listings_hote ON listings(hote_id);
CREATE INDEX idx_listings_certification ON listings(certification);
CREATE INDEX idx_listings_prix ON listings(prix_par_nuit);
CREATE INDEX idx_listings_location ON listings(latitude, longitude);

-- ============================================
-- BOOKINGS
-- ============================================
CREATE TABLE bookings (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    voyageur_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    listing_id      UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    hote_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date_arrivee    DATE NOT NULL CHECK (date_arrivee >= CURRENT_DATE),
    date_depart     DATE NOT NULL CHECK (date_depart > date_arrivee),
    nombre_nuits    INTEGER NOT NULL CHECK (nombre_nuits > 0),
    montant_total   DECIMAL(10, 2) NOT NULL CHECK (montant_total > 0),
    status          booking_status NOT NULL DEFAULT 'pending',
    payment_method  payment_method,
    payment_status  payment_status NOT NULL DEFAULT 'pending',
    transaction_id  VARCHAR(255),
    is_paid         BOOLEAN DEFAULT FALSE,
    check_in_at     TIMESTAMPTZ,
    check_out_at    TIMESTAMPTZ,
    cancelled_at    TIMESTAMPTZ,
    cancel_reason   TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_bookings_voyageur ON bookings(voyageur_id);
CREATE INDEX idx_bookings_listing ON bookings(listing_id);
CREATE INDEX idx_bookings_hote ON bookings(hote_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_dates ON bookings(date_arrivee, date_depart);

-- ============================================
-- AUDITS (Agent terrain)
-- ============================================
CREATE TABLE audits (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id      UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    agent_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    serrure         BOOLEAN DEFAULT FALSE,
    literie         BOOLEAN DEFAULT FALSE,
    sanitaires      BOOLEAN DEFAULT FALSE,
    eclairage       BOOLEAN DEFAULT FALSE,
    identite        BOOLEAN DEFAULT FALSE,
    photos_fideles  BOOLEAN DEFAULT FALSE,
    adresse         BOOLEAN DEFAULT FALSE,
    score           INTEGER DEFAULT 0,
    commentaires    TEXT,
    result          certification_status NOT NULL DEFAULT 'pending',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audits_listing ON audits(listing_id);
CREATE INDEX idx_audits_agent ON audits(agent_id);

-- ============================================
-- REVIEWS
-- ============================================
CREATE TABLE reviews (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id      UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    voyageur_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    listing_id      UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    note            INTEGER NOT NULL CHECK (note >= 1 AND note <= 5),
    commentaire     TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reviews_listing ON reviews(listing_id);
CREATE UNIQUE INDEX idx_reviews_booking ON reviews(booking_id);

-- ============================================
-- PAYMENTS
-- ============================================
CREATE TABLE payments (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id      UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount          DECIMAL(10, 2) NOT NULL,
    currency        VARCHAR(3) DEFAULT 'XOF',
    method          payment_method NOT NULL,
    status          payment_status NOT NULL DEFAULT 'pending',
    provider_ref    VARCHAR(255),
    phone_number    VARCHAR(20),
    metadata        JSONB,
    paid_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_booking ON payments(booking_id);
CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);

-- ============================================
-- NOTIFICATIONS
-- ============================================
CREATE TABLE notifications (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type            VARCHAR(50) NOT NULL,
    title           VARCHAR(255) NOT NULL,
    body            TEXT,
    data            JSONB,
    is_read         BOOLEAN DEFAULT FALSE,
    read_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);

-- ============================================
-- REVISIONS / AUDIT LOG
-- ============================================
CREATE TABLE audit_logs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID REFERENCES users(id),
    action          VARCHAR(100) NOT NULL,
    entity_type     VARCHAR(50) NOT NULL,
    entity_id       UUID,
    old_values      JSONB,
    new_values      JSONB,
    ip_address      VARCHAR(45),
    user_agent      TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action, created_at);

-- ============================================
-- TRIGGER: updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_listings_updated_at
    BEFORE UPDATE ON listings FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_bookings_updated_at
    BEFORE UPDATE ON bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_payments_updated_at
    BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at();
