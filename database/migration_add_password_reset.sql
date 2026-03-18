-- Migration: Add password reset functionality to Users table
-- Date: 2026-03-18

USE skillswapdb;

-- Add reset token columns (if MySQL version doesn't support IF NOT EXISTS, create them anyway)
ALTER TABLE Users ADD COLUMN reset_token VARCHAR(255) DEFAULT NULL;
ALTER TABLE Users ADD COLUMN token_expiry BIGINT DEFAULT NULL;

-- Create an index on reset_token for faster lookups
CREATE INDEX idx_reset_token ON Users(reset_token);

SELECT 'Password reset columns added successfully' AS status;
