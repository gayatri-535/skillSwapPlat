package com.skillswap.model;

public class User {
    public Integer id;
    public String name;
    public String email;
    public String password;
    public String location;
    public String availability;
    public Boolean isPublic;
    public Boolean isBanned;
    public String resetToken;        // For password reset
    public Long tokenExpiry;         // Token expiry timestamp (milliseconds)
}
