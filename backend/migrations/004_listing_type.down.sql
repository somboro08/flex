DROP INDEX IF EXISTS idx_listings_type;
ALTER TABLE listings DROP COLUMN IF EXISTS type_logement;
