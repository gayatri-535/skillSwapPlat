package com.skillswap;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@SpringBootApplication
public class SkillSwapApp {
    public static void main(String[] args) {
        SpringApplication.run(SkillSwapApp.class, args);
    }

    // Enable permissive CORS for local frontend (adjust origins in production)
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**").allowedOrigins("http://localhost:5500", "http://localhost:3000").allowedMethods("GET","POST","PUT","DELETE");
            }
        };
    }
}
