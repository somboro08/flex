-- ============================================
-- Flex API — Migration 006: alignement notifications
-- ============================================

ALTER TABLE notifications ADD COLUMN IF NOT EXISTS ref_id TEXT;
ALTER TABLE notifications ALTER COLUMN body SET NOT NULL;
