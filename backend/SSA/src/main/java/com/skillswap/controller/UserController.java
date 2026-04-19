package com.skillswap.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.skillswap.model.User;
import com.skillswap.service.UserService;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestParam("email") String email, @RequestParam("password") String password) {
        try {
            boolean ok = userService.authenticate(email, password);
            if (ok) {
                User user = userService.getUserByEmail(email);
                return ResponseEntity.ok(user);
            } else {
                return ResponseEntity.status(401).body("Invalid email or password");
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Login error: " + e.getMessage());
        }
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody User user) {
        try {
            if (user.email == null || user.email.isEmpty()) {
                return ResponseEntity.badRequest().body("Email is required");
            }
            if (user.password == null || user.password.isEmpty()) {
                return ResponseEntity.badRequest().body("Password is required");
            }
            if (user.name == null || user.name.isEmpty()) {
                return ResponseEntity.badRequest().body("Name is required");
            }
            userService.registerUser(user);
            return ResponseEntity.ok("User registered successfully");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Registration error: " + e.getMessage());
        }
    }

    @GetMapping
    public ResponseEntity<List<User>> listAllUsers() {
        try {
            List<User> users = userService.listAllUsers();
            return ResponseEntity.ok(users);
        } catch (Exception e) {
            return ResponseEntity.status(500).body((List<User>)null);
        }
    }

    @GetMapping("/{email}")
    public ResponseEntity<?> getUserByEmail(@PathVariable String email) {
        try {
            User user = userService.getUserByEmail(email);
            if (user == null) {
                return ResponseEntity.notFound().build();
            }
            // Don't return password
            user.password = null;
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestParam("email") String email) {
        try {
            if (email == null || email.isEmpty()) {
                return ResponseEntity.badRequest().body("Email is required");
            }
            String resetToken = userService.initiatePasswordReset(email);
            return ResponseEntity.ok(new java.util.HashMap<String, String>() {{
                put("message", "Password reset token generated. Use this token to reset your password.");
                put("token", resetToken);
                put("reset_url", "http://localhost:8080/reset-password.html?token=" + resetToken);
            }});
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/validate-reset-token")
    public ResponseEntity<?> validateResetToken(@RequestParam("token") String token) {
        try {
            if (token == null || token.isEmpty()) {
                return ResponseEntity.badRequest().body("Token is required");
            }
            boolean isValid = userService.validateResetToken(token);
            if (isValid) {
                return ResponseEntity.ok(new java.util.HashMap<String, String>() {{
                    put("message", "Token is valid");
                }});
            } else {
                return ResponseEntity.status(400).body("Invalid or expired token");
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestParam("token") String token, @RequestParam("newPassword") String newPassword) {
        try {
            if (token == null || token.isEmpty()) {
                return ResponseEntity.badRequest().body("Token is required");
            }
            if (newPassword == null || newPassword.isEmpty()) {
                return ResponseEntity.badRequest().body("New password is required");
            }
            if (newPassword.length() < 6) {
                return ResponseEntity.badRequest().body("Password must be at least 6 characters long");
            }
            userService.resetPassword(token, newPassword);
            return ResponseEntity.ok("Password reset successfully. Please log in with your new password.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Reset error: " + e.getMessage());
        }
    }

}
