package com.skillswap.service;

import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.skillswap.dao.UserDao;
import com.skillswap.model.User;

@Service
public class UserService {

    @Autowired
    private UserDao userDao;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private static final long TOKEN_EXPIRY_MILLIS = 1 * 60 * 60 * 1000; // 1 hour

    public boolean authenticate(String email, String password) {
        try {
            User user = userDao.findByEmail(email);
            if (user == null) {
                return false;
            }
            return passwordEncoder.matches(password, user.password);
        } catch (Exception e) {
            return false;
        }
    }

    public void registerUser(User user) {
        try {
            User existing = userDao.findByEmail(user.email);
            if (existing != null) {
                throw new IllegalArgumentException("User already exists with email: " + user.email);
            }
            // Hash the password before storing
            user.password = passwordEncoder.encode(user.password);
            userDao.insertUser(user);
        } catch (Exception e) {
            throw new RuntimeException("Registration failed: " + e.getMessage());
        }
    }

    public List<User> listAllUsers() {
        return userDao.listAllUsers();
    }

    public User getUserByEmail(String email) {
        return userDao.findByEmail(email);
    }

    public void updateProfile(User user) {
        userDao.updateUserProfile(user);
    }

    // Password Reset Methods
    public String initiatePasswordReset(String email) {
        User user = userDao.findByEmail(email);
        if (user == null) {
            throw new IllegalArgumentException("User not found with email: " + email);
        }

        // Generate a unique reset token
        String resetToken = UUID.randomUUID().toString();
        long expiryTime = System.currentTimeMillis() + TOKEN_EXPIRY_MILLIS;

        // Store the token in the database
        userDao.updateResetToken(email, resetToken, expiryTime);

        return resetToken;
    }

    public boolean validateResetToken(String token) {
        if (token == null || token.isEmpty()) {
            return false;
        }

        User user = userDao.findByResetToken(token);
        if (user == null) {
            return false;
        }

        // Check if token has expired
        long currentTime = System.currentTimeMillis();
        if (user.tokenExpiry <= 0L || currentTime > user.tokenExpiry) {
            return false; // Token expired
        }

        return true;
    }

    public void resetPassword(String token, String newPassword) {
        if (!validateResetToken(token)) {
            throw new IllegalArgumentException("Invalid or expired reset token");
        }

        User user = userDao.findByResetToken(token);
        if (user == null) {
            throw new IllegalArgumentException("User not found for this token");
        }

        // Hash the new password
        String hashedPassword = passwordEncoder.encode(newPassword);

        // Update password and clear the reset token
        userDao.updatePassword(user.email, hashedPassword);
    }
}
