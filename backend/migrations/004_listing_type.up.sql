-- ============================================
-- Flex API — Migration 004: type de logement
-- ============================================

ALTER TABLE listings ADD COLUMN IF NOT EXISTS type_logement VARCHAR(30) NOT NULL DEFAULT 'chambre';
CREATE INDEX IF NOT EXISTS idx_listings_type ON listings(type_logement) WHERE deleted_at IS NULL;
