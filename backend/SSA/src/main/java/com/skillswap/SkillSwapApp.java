package com.skillswap;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.lang.NonNull;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@SpringBootApplication
public class SkillSwapApp {
    public static void main(String[] args) {
        SpringApplication.run(SkillSwapApp.class, args);
    }

    // Allow localhost for development and public hosts used by deployed frontend/PWA.
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(@NonNull CorsRegistry registry) {
                registry.addMapping("/api/**")
                        .allowedOriginPatterns(
                                "http://localhost:*",
                                "http://127.0.0.1:*",
                                "http://[::1]:*",
                                "http://10.0.2.2:*",
                                "https://*.vercel.app",
                                "https://skillswapplat.onrender.com",
                                "https://skillswapplat-1.onrender.com",
                                "app://com.skillswap.platform")
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                        .allowedHeaders("*")
                        .allowCredentials(true)
                        .maxAge(3600);
            }
        };
    }
}
