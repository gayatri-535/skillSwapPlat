USE skillswapdb;

CREATE TABLE  IF NOT EXISTS Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    location VARCHAR(100),
    profile_photo_url TEXT,
    availability VARCHAR(100),
    is_public BOOLEAN DEFAULT TRUE,
    is_banned BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Skills (
    skill_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    skill_name VARCHAR(100) NOT NULL,
    skill_type ENUM('offered', 'wanted') NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS SwapRequests (
    request_id INT PRIMARY KEY AUTO_INCREMENT,
    requester_id INT,
    receiver_id INT,
    requested_skill VARCHAR(100),
    offered_skill VARCHAR(100),
    status ENUM('pending', 'accepted', 'rejected', 'cancelled') DEFAULT 'pending',
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    response_date TIMESTAMP NULL,
    FOREIGN KEY (requester_id) REFERENCES Users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES Users(user_id)
);

CREATE TABLE IF NOT EXISTS Feedback (
    feedback_id INT PRIMARY KEY AUTO_INCREMENT,
    swap_id INT,
    from_user_id INT,
    to_user_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    feedback_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (swap_id) REFERENCES SwapRequests(request_id),
    FOREIGN KEY (from_user_id) REFERENCES Users(user_id),
    FOREIGN KEY (to_user_id) REFERENCES Users(user_id)
);

CREATE TABLE IF NOT EXISTS Admins (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS AdminActions (
    action_id INT PRIMARY KEY AUTO_INCREMENT,
    admin_id INT,
    action_type VARCHAR(100),
    target_user_id INT,
    reason TEXT,
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES Admins(admin_id),
    FOREIGN KEY (target_user_id) REFERENCES Users(user_id)
);