CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    location VARCHAR(100),
    availability VARCHAR(100),
    is_public BOOLEAN DEFAULT TRUE,
    is_banned BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Backfill/normalize an existing users table that may come from older schemas.
ALTER TABLE users ADD COLUMN IF NOT EXISTS user_id INTEGER;
ALTER TABLE users ADD COLUMN IF NOT EXISTS name VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS location VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS availability VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_public BOOLEAN;
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_banned BOOLEAN;
ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'users'
          AND column_name = 'id'
    ) THEN
        EXECUTE 'UPDATE users SET user_id = id WHERE user_id IS NULL';
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_class
        WHERE relkind = 'S' AND relname = 'users_user_id_seq'
    ) THEN
        CREATE SEQUENCE users_user_id_seq;
    END IF;
END $$;

ALTER TABLE users ALTER COLUMN user_id SET DEFAULT nextval('users_user_id_seq');
UPDATE users SET user_id = nextval('users_user_id_seq') WHERE user_id IS NULL;
SELECT setval('users_user_id_seq', COALESCE((SELECT MAX(user_id) FROM users), 1), true);

UPDATE users SET is_public = TRUE WHERE is_public IS NULL;
UPDATE users SET is_banned = FALSE WHERE is_banned IS NULL;

ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_token VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS token_expiry BIGINT;

CREATE TABLE IF NOT EXISTS swaprequests (
    id SERIAL PRIMARY KEY,
    requesterid INT NOT NULL,
    receiverid INT NOT NULL,
    requestedskill VARCHAR(100),
    offeredskill VARCHAR(100),
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_swap_requester FOREIGN KEY (requesterid) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_swap_receiver FOREIGN KEY (receiverid) REFERENCES users(user_id) ON DELETE CASCADE
);
