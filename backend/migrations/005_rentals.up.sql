-- ============================================
-- Flex API — Migration 005: locations mensuelles
-- ============================================

CREATE TYPE rental_period_status AS ENUM ('active', 'notice_given', 'terminated', 'expired');
CREATE TYPE rental_payment_status AS ENUM ('on_time', 'late', 'advance', 'unpaid', 'refunded');
CREATE TYPE rental_request_type AS ENUM ('advance_payment', 'refund', 'renewal');
CREATE TYPE rental_request_status AS ENUM ('pending', 'approved', 'rejected');

-- Locations (baux mensuels)
CREATE TABLE IF NOT EXISTS rentals (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id      UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    hote_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    voyageur_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    start_date      DATE NOT NULL,
    end_date        DATE,
    monthly_rent    DECIMAL(12, 2) NOT NULL CHECK (monthly_rent > 0),
    caution         DECIMAL(12, 2) DEFAULT 0,
    billing_day     INTEGER NOT NULL DEFAULT 5 CHECK (billing_day >= 1 AND billing_day <= 28),
    period_status   rental_period_status NOT NULL DEFAULT 'active',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_rentals_listing ON rentals(listing_id);
CREATE INDEX IF NOT EXISTS idx_rentals_hote ON rentals(hote_id);
CREATE INDEX IF NOT EXISTS idx_rentals_voyageur ON rentals(voyageur_id);
CREATE INDEX IF NOT EXISTS idx_rentals_status ON rentals(period_status);

-- Échéances de loyer
CREATE TABLE IF NOT EXISTS rental_payments (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rental_id       UUID NOT NULL REFERENCES rentals(id) ON DELETE CASCADE,
    period_label    VARCHAR(7) NOT NULL,
    amount          DECIMAL(12, 2) NOT NULL,
    due_date        DATE NOT NULL,
    paid_at         TIMESTAMPTZ,
    status          rental_payment_status NOT NULL DEFAULT 'unpaid',
    transaction_ref VARCHAR(255),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (rental_id, period_label)
);

CREATE INDEX IF NOT EXISTS idx_rental_payments_rental ON rental_payments(rental_id);

-- Demandes locataire (avance, remboursement, renouvellement)
CREATE TABLE IF NOT EXISTS rental_requests (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rental_id       UUID NOT NULL REFERENCES rentals(id) ON DELETE CASCADE,
    voyageur_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type            rental_request_type NOT NULL,
    message         TEXT,
    amount          DECIMAL(12, 2),
    status          rental_request_status NOT NULL DEFAULT 'pending',
    responded_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rental_requests_rental ON rental_requests(rental_id);
CREATE INDEX IF NOT EXISTS idx_rental_requests_status ON rental_requests(status);

DROP TRIGGER IF EXISTS trg_rentals_updated_at ON rentals;
CREATE TRIGGER trg_rentals_updated_at
    BEFORE UPDATE ON rentals FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trg_rental_payments_updated_at ON rental_payments;
CREATE TRIGGER trg_rental_payments_updated_at
    BEFORE UPDATE ON rental_payments FOR EACH ROW EXECUTE FUNCTION update_updated_at();
