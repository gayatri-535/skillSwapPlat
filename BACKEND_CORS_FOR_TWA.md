# Backend CORS Configuration for TWA

## Current CORS Setup
Your backend at `SkillSwapApp.java` needs to allow requests from the TWA app.

## Required Update

### 1. Modify SkillSwapApp.java CORS Configuration

Update the `corsConfigurer()` method to include the TWA app package:

```java
@Bean
public WebMvcConfigurer corsConfigurer() {
    return new WebMvcConfigurer() {
        @Override
        public void addCorsMappings(CorsRegistry registry) {
            registry.addMapping("/api/**")
                .allowedOrigins(
                    "https://skillswapplat-1.onrender.com",      // Main PWA
                    "https://*.vercel.app",                      // Vercel deployments
                    "https://*.herokuapp.com",                   // If needed
                    "app://com.skillswap.platform"               // TWA Android App (NEW)
                )
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
        }
    };
}
```

### 2. Also Allow Custom Headers (if needed by TWA)

```java
registry.addMapping("/api/**")
    // ... other settings above ...
    .allowedHeaders("Accept", "Accept-Language", "Content-Type", 
                   "X-Requested-With", "Authorization", "X-Custom-Header")
    .exposedHeaders("Content-Type", "X-Custom-Header")
    // ...
```

### 3. Test CORS After Deploy

```powershell
# Test OPTIONS request
Invoke-WebRequest -Uri "https://skillswapplat-1.onrender.com/api/users" `
  -Method Options `
  -Headers @{"Origin"="app://com.skillswap.platform"} `
  -UseBasicParsing
```

Should return headers including:
```
Access-Control-Allow-Origin: app://com.skillswap.platform
```

---

## Location in Project

Update this file after completing the Android build:
```
backend/SSA/src/main/java/com/skillswap/SkillSwapApp.java
```

---

## Deployment

After updating CORS:

```powershell
cd backend/SSA
mvn clean package
# Deploy to Render.com or your hosting
```

---

## Verify PWA Manifest Supports TWA

Your `manifest.json` is already compatible. The TWA will:
- Use your icons from manifest.json
- Respect the app name and theme colors
- Work with your service worker for offline support
- Leverage all existing PWA features

No manifest changes needed! ✅
