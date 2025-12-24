package com.skillswap.service;

import com.skillswap.dao.UserDao;
import com.skillswap.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {

    @Autowired
    private UserDao userDao;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public boolean authenticate(String email, String password) {
        try {
            User user = userDao.findByEmail(email);
            if (user == null) {
                return false;
            }
            return passwordEncoder.matches(password, user.password);
        } catch (Exception e) {
            e.printStackTrace();
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
            e.printStackTrace();
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
}
