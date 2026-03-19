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
