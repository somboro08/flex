-- ============================================
-- Flex API — Migration 002: visites
-- ============================================

CREATE TYPE visit_status AS ENUM ('pending', 'confirmed', 'completed', 'cancelled');

CREATE TABLE IF NOT EXISTS visits (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id      UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    voyageur_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    hote_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date_visite     DATE NOT NULL,
    time_slot       VARCHAR(50) NOT NULL,
    message         TEXT,
    status          visit_status NOT NULL DEFAULT 'pending',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_visits_listing ON visits(listing_id);
CREATE INDEX IF NOT EXISTS idx_visits_voyageur ON visits(voyageur_id);
CREATE INDEX IF NOT EXISTS idx_visits_hote ON visits(hote_id);
CREATE INDEX IF NOT EXISTS idx_visits_status ON visits(status);

DROP TRIGGER IF EXISTS trg_visits_updated_at ON visits;
CREATE TRIGGER trg_visits_updated_at
    BEFORE UPDATE ON visits FOR EACH ROW EXECUTE FUNCTION update_updated_at();
