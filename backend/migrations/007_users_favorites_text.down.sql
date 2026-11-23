-- Rollback: text[] -> uuid[]
ALTER TABLE users ALTER COLUMN favorites TYPE uuid[] USING favorites::uuid[];