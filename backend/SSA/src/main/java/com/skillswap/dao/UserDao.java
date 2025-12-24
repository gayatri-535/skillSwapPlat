package com.skillswap.dao;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.skillswap.model.User;

@Repository
public class UserDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public User findByEmail(String email) {
        String sql = "SELECT user_id, name, email, password_hash, location, availability, is_public, is_banned FROM users WHERE email = ?";
        List<User> users = jdbcTemplate.query(sql, (rs, rowNum) -> {
            User user = new User();
            user.id = rs.getInt("user_id");
            user.name = rs.getString("name");
            user.email = rs.getString("email");
            user.password = rs.getString("password_hash");
            user.location = rs.getString("location");
            user.availability = rs.getString("availability");
            user.isPublic = rs.getBoolean("is_public");
            user.isBanned = rs.getBoolean("is_banned");
            return user;
        }, email);
        return users.isEmpty() ? null : users.get(0);
    }

    public void insertUser(User user) {
        String sql = "INSERT INTO users (name, email, password_hash, location, availability, is_public, is_banned) VALUES (?, ?, ?, ?, ?, ?, ?)";
        jdbcTemplate.update(sql, 
            user.name, 
            user.email, 
            user.password, 
            user.location != null ? user.location : "", 
            user.availability != null ? user.availability : "", 
            user.isPublic != false ? user.isPublic : true,  // Default to true (public)
            false  // Default to false (not banned)
        );
    }

    public List<User> listAllUsers() {
        String sql = "SELECT user_id, name, email, location, availability, is_public, is_banned FROM users WHERE is_banned IS NULL OR is_banned = false";
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            User user = new User();
            user.id = rs.getInt("user_id");
            user.name = rs.getString("name");
            user.email = rs.getString("email");
            user.location = rs.getString("location");
            user.availability = rs.getString("availability");
            user.isPublic = rs.getBoolean("is_public");
            user.isBanned = rs.getBoolean("is_banned");
            // Note: password is not included in response for security
            return user;
        });
    }

    public void updateUserProfile(User user) {
        String sql = "UPDATE users SET name = ?, location = ?, availability = ?, is_public = ? WHERE user_id = ?";
        jdbcTemplate.update(sql, user.name, user.location, user.availability, user.isPublic, user.id);
    }
}
