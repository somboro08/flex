-- favorites: uuid[] -> text[] (pgx ne sait pas scanner uuid[] sous GORM/database-sql)
ALTER TABLE users ALTER COLUMN favorites TYPE text[] USING favorites::text[];