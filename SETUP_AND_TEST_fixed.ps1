#!/usr/bin/env pwsh
# Complete SkillSwap Setup and Testing Guide
# Run this script to set up and test the complete system

Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║        SkillSwap Platform - Complete Setup Guide               ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

$SkillswapRoot = "c:\Users\HP\skillswapplat"
$BackendDir = "$SkillswapRoot\backend\SSA"
$FrontendDir = "$SkillswapRoot\frontend"

Write-Host "📋 SETUP CHECKLIST" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""

# Check MySQL
Write-Host "1️⃣  Checking MySQL..." -ForegroundColor Yellow
try {
    $result = mysql -u root -e "SELECT 'MySQL is running'" 2>&1
    if ($result -match "MySQL is running") {
        Write-Host "   ✓ MySQL is running" -ForegroundColor Green
    }
} catch {
    Write-Host "   ✗ MySQL not running. Please start MySQL server." -ForegroundColor Red
    exit 1
}

# Check Java
Write-Host "2️⃣  Checking Java..." -ForegroundColor Yellow
try {
    $version = java -version 2>&1
    if ($version -match "24\.0\.1") {
        Write-Host "   ✓ Java 24.0.1 is available" -ForegroundColor Green
    }
} catch {
    Write-Host "   ✗ Java not found. Please install Java." -ForegroundColor Red
    exit 1
}

# Check Backend JAR
Write-Host "3️⃣  Checking Backend JAR..." -ForegroundColor Yellow
if (Test-Path "$BackendDir\target\skillswap-backend-1.0.0.jar") {
    Write-Host "   ✓ Backend JAR exists" -ForegroundColor Green
} else {
    Write-Host "   ✗ Backend JAR not found. Building..." -ForegroundColor Yellow
    cd $BackendDir
    mvn clean package -DskipTests
}

Write-Host ""
Write-Host "🚀 STARTING SERVICES" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""

# Start Backend
Write-Host "Starting Backend Server..." -ForegroundColor Yellow
$env:DB_URL = "jdbc:mysql://localhost:3306/skillswapdb"
$env:DB_USER = "root"
$env:DB_PASS = ""

Write-Host "Command: java -jar $BackendDir\target\skillswap-backend-1.0.0.jar" -ForegroundColor DarkGray
Write-Host "Backend will start on http://localhost:8080" -ForegroundColor Cyan
Write-Host ""

# Note: Backend starts in foreground, user needs to Ctrl+C to proceed
Write-Host "⏳ Starting backend in separate window..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$BackendDir'; `$env:DB_URL='jdbc:mysql://localhost:3306/skillswapdb'; `$env:DB_USER='root'; `$env:DB_PASS=''; java -jar target/skillswap-backend-1.0.0.jar"

Start-Sleep -Seconds 8

Write-Host ""
Write-Host "✅ Backend is starting (check the new window)" -ForegroundColor Green
Write-Host ""

# Check if Backend is responding
Write-Host "Checking Backend Health..." -ForegroundColor Yellow
$maxRetries = 5
$retries = 0
while ($retries -lt $maxRetries) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/api/users" -Method GET -TimeoutSec 2 -ErrorAction Stop
        Write-Host "   ✓ Backend is responding" -ForegroundColor Green
        break
    } catch {
        $retries++
        if ($retries -lt $maxRetries) {
            Write-Host "   ⏳ Waiting for backend... ($retries/$maxRetries)" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
}

if ($retries -eq $maxRetries) {
    Write-Host "   ✗ Backend is not responding. Check the backend window for errors." -ForegroundColor Red
}

Write-Host ""
Write-Host "📱 FRONTEND OPTIONS" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "Choose how to serve the frontend:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Option 1: Python HTTP Server (Recommended)" -ForegroundColor Green
Write-Host "  Command: python -m http.server 5500" -ForegroundColor DarkGray
Write-Host "  URL: http://localhost:5500" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Option 2: Node.js http-server" -ForegroundColor Green
Write-Host "  Command: npx http-server -p 5500" -ForegroundColor DarkGray
Write-Host "  URL: http://localhost:5500" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Option 3: VS Code Live Server" -ForegroundColor Green
Write-Host "  1. Install 'Live Server' extension" -ForegroundColor DarkGray
Write-Host "  2. Right-click index.html → Open with Live Server" -ForegroundColor DarkGray
Write-Host "  URL: http://localhost:5500" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Starting Python HTTP Server on port 5500..." -ForegroundColor Yellow
Write-Host ""
cd $FrontendDir
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$FrontendDir'; python -m http.server 5500"

Start-Sleep -Seconds 2

Write-Host ""
Write-Host "📖 QUICK START GUIDE" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "1. 🔧 API Tester (Testing Tool)" -ForegroundColor Green
Write-Host "   URL: http://localhost:5500/api-test.html" -ForegroundColor Yellow
Write-Host "   Features:" -ForegroundColor DarkGray
Write-Host "   - Register/Login users" -ForegroundColor DarkGray
Write-Host "   - Create swap requests" -ForegroundColor DarkGray
Write-Host "   - Quick populate with test data" -ForegroundColor DarkGray
Write-Host "   - View API responses" -ForegroundColor DarkGray
Write-Host ""

Write-Host "2. 🏠 Main Application" -ForegroundColor Green
Write-Host "   URL: http://localhost:5500/index.html" -ForegroundColor Yellow
Write-Host "   Features:" -ForegroundColor DarkGray
Write-Host "   - Sign up and register" -ForegroundColor DarkGray
Write-Host "   - Browse available skills to swap" -ForegroundColor DarkGray
Write-Host "   - Manage your swap requests" -ForegroundColor DarkGray
Write-Host "   - View user profile" -ForegroundColor DarkGray
Write-Host ""

Write-Host "3. 📚 Documentation" -ForegroundColor Green
Write-Host "   File: FRONTEND_INTEGRATION.md" -ForegroundColor Yellow
Write-Host ""

Write-Host "🧪 TESTING WORKFLOW" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "Step 1: Generate Test Data" -ForegroundColor Green
Write-Host "  1. Open http://localhost:5500/api-test.html" -ForegroundColor DarkGray
Write-Host "  2. Go to 'Quick Populate' tab" -ForegroundColor DarkGray
Write-Host "  3. Click 'Generate All Test Data'" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Step 2: Test User Registration" -ForegroundColor Green
Write-Host "  1. Open http://localhost:5500/index.html" -ForegroundColor DarkGray
Write-Host "  2. Click 'Sign Up Now'" -ForegroundColor DarkGray
Write-Host "  3. Register new account" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Step 3: Test Login & Profile" -ForegroundColor Green
Write-Host "  1. Click 'Login'" -ForegroundColor DarkGray
Write-Host "  2. Enter credentials" -ForegroundColor DarkGray
Write-Host "  3. View profile" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Step 4: Test Skill Swaps" -ForegroundColor Green
Write-Host "  1. Click 'Browse Swaps'" -ForegroundColor DarkGray
Write-Host "  2. Create new swap request" -ForegroundColor DarkGray
Write-Host "  3. Login as another user to accept/decline" -ForegroundColor DarkGray
Write-Host ""

Write-Host "💡 SAMPLE TEST DATA" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "Test Users (auto-generated):" -ForegroundColor Yellow
Write-Host "  Email: alice@test.com, bob@test.com, carol@test.com, etc." -ForegroundColor DarkGray
Write-Host "  Password: pass123" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Test Swaps: 10 sample swap requests" -ForegroundColor Yellow
Write-Host ""

Write-Host "🌐 ENDPOINTS" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "Backend API:" -ForegroundColor Yellow
Write-Host "  Base URL: http://localhost:8080/api" -ForegroundColor DarkGray
Write-Host "  Users: POST /users/register, POST /users/login, GET /users" -ForegroundColor DarkGray
Write-Host "  Swaps: POST /swaps, GET /swaps, POST /swaps/{id}/accept" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Frontend:" -ForegroundColor Yellow
Write-Host "  Home: http://localhost:5500/index.html" -ForegroundColor DarkGray
Write-Host "  Login: http://localhost:5500/login.html" -ForegroundColor DarkGray
Write-Host "  Register: http://localhost:5500/register.html" -ForegroundColor DarkGray
Write-Host "  Profile: http://localhost:5500/profile.html" -ForegroundColor DarkGray
Write-Host "  Swaps: http://localhost:5500/swap-requests.html" -ForegroundColor DarkGray
Write-Host "  API Tester: http://localhost:5500/api-test.html" -ForegroundColor DarkGray
Write-Host ""

Write-Host "❓ TROUBLESHOOTING" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "Backend not starting:" -ForegroundColor Yellow
Write-Host "  1. Check MySQL is running" -ForegroundColor DarkGray
Write-Host "  2. Check port 8080 is not in use" -ForegroundColor DarkGray
Write-Host "  3. Review backend console output" -ForegroundColor DarkGray
Write-Host ""

Write-Host "CORS errors:" -ForegroundColor Yellow
Write-Host "  1. Check backend is running on http://localhost:8080" -ForegroundColor DarkGray
Write-Host "  2. Check frontend is on http://localhost:5500" -ForegroundColor DarkGray
Write-Host "  3. Review browser console for details" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Database errors:" -ForegroundColor Yellow
Write-Host "  1. Verify MySQL is running" -ForegroundColor DarkGray
Write-Host "  2. Check credentials in backend command" -ForegroundColor DarkGray
Write-Host "  3. Re-import schema if needed" -ForegroundColor DarkGray
Write-Host ""

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              🎉 Setup Complete! Ready for Testing               ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "👉 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Open http://localhost:5500/api-test.html in your browser" -ForegroundColor Green
Write-Host "  2. Use 'Quick Populate' to generate test data" -ForegroundColor Green
Write-Host "  3. Test the application at http://localhost:5500" -ForegroundColor Green
Write-Host ""
Write-Host "📧 Questions? Check FRONTEND_INTEGRATION.md for detailed documentation" -ForegroundColor Cyan
Write-Host ""
#!/usr/bin/env pwsh
# Complete SkillSwap Setup and Testing Guide
# Run this script to set up and test the complete system

Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║        SkillSwap Platform - Complete Setup Guide               ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

$SkillswapRoot = "c:\Users\HP\skillswapplat"
$BackendDir = "$SkillswapRoot\backend\SSA"
$FrontendDir = "$SkillswapRoot\frontend"

Write-Host "📋 SETUP CHECKLIST" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""

# Check MySQL
Write-Host "1️⃣  Checking MySQL..." -ForegroundColor Yellow
try {
    $result = mysql -u root -e "SELECT 'MySQL is running'" 2>&1
    if ($result -match "MySQL is running") {
        Write-Host "   ✓ MySQL is running" -ForegroundColor Green
    }
} catch {
    Write-Host "   ✗ MySQL not running. Please start MySQL server." -ForegroundColor Red
    exit 1
}

# Check Java
Write-Host "2️⃣  Checking Java..." -ForegroundColor Yellow
try {
    $version = java -version 2>&1
    if ($version -match "24\.0\.1") {
        Write-Host "   ✓ Java 24.0.1 is available" -ForegroundColor Green
    }
} catch {
    Write-Host "   ✗ Java not found. Please install Java." -ForegroundColor Red
    exit 1
}

# Check Backend JAR
Write-Host "3️⃣  Checking Backend JAR..." -ForegroundColor Yellow
if (Test-Path "$BackendDir\target\skillswap-backend-1.0.0.jar") {
    Write-Host "   ✓ Backend JAR exists" -ForegroundColor Green
} else {
    Write-Host "   ✗ Backend JAR not found. Building..." -ForegroundColor Yellow
    cd $BackendDir
    mvn clean package -DskipTests
}

Write-Host ""
Write-Host "🚀 STARTING SERVICES" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""

# Start Backend
Write-Host "Starting Backend Server..." -ForegroundColor Yellow
$env:DB_URL = "jdbc:mysql://localhost:3306/skillswapdb"
$env:DB_USER = "root"
$env:DB_PASS = ""

Write-Host "Command: java -jar $BackendDir\target\skillswap-backend-1.0.0.jar" -ForegroundColor DarkGray
Write-Host "Backend will start on http://localhost:8080" -ForegroundColor Cyan
Write-Host ""

# Note: Backend starts in foreground, user needs to Ctrl+C to proceed
Write-Host "⏳ Starting backend in separate window..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$BackendDir'; `$env:DB_URL='jdbc:mysql://localhost:3306/skillswapdb'; `$env:DB_USER='root'; `$env:DB_PASS=''; java -jar target/skillswap-backend-1.0.0.jar"

Start-Sleep -Seconds 8

Write-Host ""
Write-Host "✅ Backend is starting (check the new window)" -ForegroundColor Green
Write-Host ""

# Check if Backend is responding
Write-Host "Checking Backend Health..." -ForegroundColor Yellow
$maxRetries = 5
$retries = 0
while ($retries -lt $maxRetries) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/api/users" -Method GET -TimeoutSec 2 -ErrorAction Stop
        Write-Host "   ✓ Backend is responding" -ForegroundColor Green
        break
    } catch {
        $retries++
        if ($retries -lt $maxRetries) {
            Write-Host "   ⏳ Waiting for backend... ($retries/$maxRetries)" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
}

if ($retries -eq $maxRetries) {
    Write-Host "   ✗ Backend is not responding. Check the backend window for errors." -ForegroundColor Red
}

Write-Host ""
Write-Host "📱 FRONTEND OPTIONS" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "Choose how to serve the frontend:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Option 1: Python HTTP Server (Recommended)" -ForegroundColor Green
Write-Host "  Command: python -m http.server 5500" -ForegroundColor DarkGray
Write-Host "  URL: http://localhost:5500" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Option 2: Node.js http-server" -ForegroundColor Green
Write-Host "  Command: npx http-server -p 5500" -ForegroundColor DarkGray
Write-Host "  URL: http://localhost:5500" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Option 3: VS Code Live Server" -ForegroundColor Green
Write-Host "  1. Install 'Live Server' extension" -ForegroundColor DarkGray
Write-Host "  2. Right-click index.html → Open with Live Server" -ForegroundColor DarkGray
Write-Host "  URL: http://localhost:5500" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Starting Python HTTP Server on port 5500..." -ForegroundColor Yellow
Write-Host ""
cd $FrontendDir
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$FrontendDir'; python -m http.server 5500"

Start-Sleep -Seconds 2

Write-Host ""
Write-Host "📖 QUICK START GUIDE" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "1. 🔧 API Tester (Testing Tool)" -ForegroundColor Green
Write-Host "   URL: http://localhost:5500/api-test.html" -ForegroundColor Yellow
Write-Host "   Features:" -ForegroundColor DarkGray
Write-Host "   - Register/Login users" -ForegroundColor DarkGray
Write-Host "   - Create swap requests" -ForegroundColor DarkGray
Write-Host "   - Quick populate with test data" -ForegroundColor DarkGray
Write-Host "   - View API responses" -ForegroundColor DarkGray
Write-Host ""

Write-Host "2. 🏠 Main Application" -ForegroundColor Green
Write-Host "   URL: http://localhost:5500/index.html" -ForegroundColor Yellow
Write-Host "   Features:" -ForegroundColor DarkGray
Write-Host "   - Sign up and register" -ForegroundColor DarkGray
Write-Host "   - Browse available skills to swap" -ForegroundColor DarkGray
Write-Host "   - Manage your swap requests" -ForegroundColor DarkGray
Write-Host "   - View user profile" -ForegroundColor DarkGray
Write-Host ""

Write-Host "3. 📚 Documentation" -ForegroundColor Green
Write-Host "   File: FRONTEND_INTEGRATION.md" -ForegroundColor Yellow
Write-Host ""

Write-Host "🧪 TESTING WORKFLOW" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "Step 1: Generate Test Data" -ForegroundColor Green
Write-Host "  1. Open http://localhost:5500/api-test.html" -ForegroundColor DarkGray
Write-Host "  2. Go to 'Quick Populate' tab" -ForegroundColor DarkGray
Write-Host "  3. Click 'Generate All Test Data'" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Step 2: Test User Registration" -ForegroundColor Green
Write-Host "  1. Open http://localhost:5500/index.html" -ForegroundColor DarkGray
Write-Host "  2. Click 'Sign Up Now'" -ForegroundColor DarkGray
Write-Host "  3. Register new account" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Step 3: Test Login & Profile" -ForegroundColor Green
Write-Host "  1. Click 'Login'" -ForegroundColor DarkGray
Write-Host "  2. Enter credentials" -ForegroundColor DarkGray
Write-Host "  3. View profile" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Step 4: Test Skill Swaps" -ForegroundColor Green
Write-Host "  1. Click 'Browse Swaps'" -ForegroundColor DarkGray
Write-Host "  2. Create new swap request" -ForegroundColor DarkGray
Write-Host "  3. Login as another user to accept/decline" -ForegroundColor DarkGray
Write-Host ""

Write-Host "💡 SAMPLE TEST DATA" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "Test Users (auto-generated):" -ForegroundColor Yellow
Write-Host "  Email: alice@test.com, bob@test.com, carol@test.com, etc." -ForegroundColor DarkGray
Write-Host "  Password: pass123" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Test Swaps: 10 sample swap requests" -ForegroundColor Yellow
Write-Host ""

Write-Host "🌐 ENDPOINTS" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "Backend API:" -ForegroundColor Yellow
Write-Host "  Base URL: http://localhost:8080/api" -ForegroundColor DarkGray
Write-Host "  Users: POST /users/register, POST /users/login, GET /users" -ForegroundColor DarkGray
Write-Host "  Swaps: POST /swaps, GET /swaps, POST /swaps/{id}/accept" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Frontend:" -ForegroundColor Yellow
Write-Host "  Home: http://localhost:5500/index.html" -ForegroundColor DarkGray
Write-Host "  Login: http://localhost:5500/login.html" -ForegroundColor DarkGray
Write-Host "  Register: http://localhost:5500/register.html" -ForegroundColor DarkGray
Write-Host "  Profile: http://localhost:5500/profile.html" -ForegroundColor DarkGray
Write-Host "  Swaps: http://localhost:5500/swap-requests.html" -ForegroundColor DarkGray
Write-Host "  API Tester: http://localhost:5500/api-test.html" -ForegroundColor DarkGray
Write-Host ""

Write-Host "❓ TROUBLESHOOTING" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "Backend not starting:" -ForegroundColor Yellow
Write-Host "  1. Check MySQL is running" -ForegroundColor DarkGray
Write-Host "  2. Check port 8080 is not in use" -ForegroundColor DarkGray
Write-Host "  3. Review backend console output" -ForegroundColor DarkGray
Write-Host ""

Write-Host "CORS errors:" -ForegroundColor Yellow
Write-Host "  1. Check backend is running on http://localhost:8080" -ForegroundColor DarkGray
Write-Host "  2. Check frontend is on http://localhost:5500" -ForegroundColor DarkGray
Write-Host "  3. Review browser console for details" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Database errors:" -ForegroundColor Yellow
Write-Host "  1. Verify MySQL is running" -ForegroundColor DarkGray
Write-Host "  2. Check credentials in backend command" -ForegroundColor DarkGray
Write-Host "  3. Re-import schema if needed" -ForegroundColor DarkGray
Write-Host ""

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              🎉 Setup Complete! Ready for Testing               ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "👉 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Open http://localhost:5500/api-test.html in your browser" -ForegroundColor Green
Write-Host "  2. Use 'Quick Populate' to generate test data" -ForegroundColor Green
Write-Host "  3. Test the application at http://localhost:5500" -ForegroundColor Green
Write-Host ""
Write-Host "📧 Questions? Check FRONTEND_INTEGRATION.md for detailed documentation" -ForegroundColor Cyan
Write-Host ""
#!/usr/bin/env pwsh
# Complete SkillSwap Setup and Testing Guide
# Run this script to set up and test the complete system

Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║        SkillSwap Platform - Complete Setup Guide               ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

$SkillswapRoot = "c:\Users\HP\skillswapplat"
$BackendDir = "$SkillswapRoot\backend\SSA"
$FrontendDir = "$SkillswapRoot\frontend"

Write-Host "📋 SETUP CHECKLIST" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""

# Check MySQL
Write-Host "1️⃣  Checking MySQL..." -ForegroundColor Yellow
try {
    $result = mysql -u root -e "SELECT 'MySQL is running'" 2>&1
    if ($result -match "MySQL is running") {
        Write-Host "   ✓ MySQL is running" -ForegroundColor Green
    }
} catch {
    Write-Host "   ✗ MySQL not running. Please start MySQL server." -ForegroundColor Red
    exit 1
}

# Check Java
Write-Host "2️⃣  Checking Java..." -ForegroundColor Yellow
try {
    $version = java -version 2>&1
    if ($version -match "24\.0\.1") {
        Write-Host "   ✓ Java 24.0.1 is available" -ForegroundColor Green
    }
} catch {
    Write-Host "   ✗ Java not found. Please install Java." -ForegroundColor Red
    exit 1
}

# Check Backend JAR
Write-Host "3️⃣  Checking Backend JAR..." -ForegroundColor Yellow
if (Test-Path "$BackendDir\target\skillswap-backend-1.0.0.jar") {
    Write-Host "   ✓ Backend JAR exists" -ForegroundColor Green
} else {
    Write-Host "   ✗ Backend JAR not found. Building..." -ForegroundColor Yellow
    cd $BackendDir
    mvn clean package -DskipTests
}

Write-Host ""
Write-Host "🚀 STARTING SERVICES" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""

# Start Backend
Write-Host "Starting Backend Server..." -ForegroundColor Yellow
$env:DB_URL = "jdbc:mysql://localhost:3306/skillswapdb"
$env:DB_USER = "root"
$env:DB_PASS = ""

Write-Host "Command: java -jar $BackendDir\target\skillswap-backend-1.0.0.jar" -ForegroundColor DarkGray
Write-Host "Backend will start on http://localhost:8080" -ForegroundColor Cyan
Write-Host ""

# Note: Backend starts in foreground, user needs to Ctrl+C to proceed
Write-Host "⏳ Starting backend in separate window..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$BackendDir'; `$env:DB_URL='jdbc:mysql://localhost:3306/skillswapdb'; `$env:DB_USER='root'; `$env:DB_PASS=''; java -jar target/skillswap-backend-1.0.0.jar"

Start-Sleep -Seconds 8

Write-Host ""
Write-Host "✅ Backend is starting (check the new window)" -ForegroundColor Green
Write-Host ""

# Check if Backend is responding
Write-Host "Checking Backend Health..." -ForegroundColor Yellow
$maxRetries = 5
$retries = 0
while ($retries -lt $maxRetries) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/api/users" -Method GET -TimeoutSec 2 -ErrorAction Stop
        Write-Host "   ✓ Backend is responding" -ForegroundColor Green
        break
    } catch {
        $retries++
        if ($retries -lt $maxRetries) {
            Write-Host "   ⏳ Waiting for backend... ($retries/$maxRetries)" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
}

if ($retries -eq $maxRetries) {
    Write-Host "   ✗ Backend is not responding. Check the backend window for errors." -ForegroundColor Red
}

Write-Host ""
Write-Host "📱 FRONTEND OPTIONS" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "Choose how to serve the frontend:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Option 1: Python HTTP Server (Recommended)" -ForegroundColor Green
Write-Host "  Command: python -m http.server 5500" -ForegroundColor DarkGray
Write-Host "  URL: http://localhost:5500" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Option 2: Node.js http-server" -ForegroundColor Green
Write-Host "  Command: npx http-server -p 5500" -ForegroundColor DarkGray
Write-Host "  URL: http://localhost:5500" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Option 3: VS Code Live Server" -ForegroundColor Green
Write-Host "  1. Install 'Live Server' extension" -ForegroundColor DarkGray
Write-Host "  2. Right-click index.html → Open with Live Server" -ForegroundColor DarkGray
Write-Host "  URL: http://localhost:5500" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Starting Python HTTP Server on port 5500..." -ForegroundColor Yellow
Write-Host ""
cd $FrontendDir
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$FrontendDir'; python -m http.server 5500"

Start-Sleep -Seconds 2

Write-Host ""
Write-Host "📖 QUICK START GUIDE" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "1. 🔧 API Tester (Testing Tool)" -ForegroundColor Green
Write-Host "   URL: http://localhost:5500/api-test.html" -ForegroundColor Yellow
Write-Host "   Features:" -ForegroundColor DarkGray
Write-Host "   - Register/Login users" -ForegroundColor DarkGray
Write-Host "   - Create swap requests" -ForegroundColor DarkGray
Write-Host "   - Quick populate with test data" -ForegroundColor DarkGray
Write-Host "   - View API responses" -ForegroundColor DarkGray
Write-Host ""

Write-Host "2. 🏠 Main Application" -ForegroundColor Green
Write-Host "   URL: http://localhost:5500/index.html" -ForegroundColor Yellow
Write-Host "   Features:" -ForegroundColor DarkGray
Write-Host "   - Sign up and register" -ForegroundColor DarkGray
Write-Host "   - Browse available skills to swap" -ForegroundColor DarkGray
Write-Host "   - Manage your swap requests" -ForegroundColor DarkGray
Write-Host "   - View user profile" -ForegroundColor DarkGray
Write-Host ""

Write-Host "3. 📚 Documentation" -ForegroundColor Green
Write-Host "   File: FRONTEND_INTEGRATION.md" -ForegroundColor Yellow
Write-Host ""

Write-Host "🧪 TESTING WORKFLOW" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "Step 1: Generate Test Data" -ForegroundColor Green
Write-Host "  1. Open http://localhost:5500/api-test.html" -ForegroundColor DarkGray
Write-Host "  2. Go to 'Quick Populate' tab" -ForegroundColor DarkGray
Write-Host "  3. Click 'Generate All Test Data'" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Step 2: Test User Registration" -ForegroundColor Green
Write-Host "  1. Open http://localhost:5500/index.html" -ForegroundColor DarkGray
Write-Host "  2. Click 'Sign Up Now'" -ForegroundColor DarkGray
Write-Host "  3. Register new account" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Step 3: Test Login & Profile" -ForegroundColor Green
Write-Host "  1. Click 'Login'" -ForegroundColor DarkGray
Write-Host "  2. Enter credentials" -ForegroundColor DarkGray
Write-Host "  3. View profile" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Step 4: Test Skill Swaps" -ForegroundColor Green
Write-Host "  1. Click 'Browse Swaps'" -ForegroundColor DarkGray
Write-Host "  2. Create new swap request" -ForegroundColor DarkGray
Write-Host "  3. Login as another user to accept/decline" -ForegroundColor DarkGray
Write-Host ""

Write-Host "💡 SAMPLE TEST DATA" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "Test Users (auto-generated):" -ForegroundColor Yellow
Write-Host "  Email: alice@test.com, bob@test.com, carol@test.com, etc." -ForegroundColor DarkGray
Write-Host "  Password: pass123" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Test Swaps: 10 sample swap requests" -ForegroundColor Yellow
Write-Host ""

Write-Host "🌐 ENDPOINTS" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "Backend API:" -ForegroundColor Yellow
Write-Host "  Base URL: http://localhost:8080/api" -ForegroundColor DarkGray
Write-Host "  Users: POST /users/register, POST /users/login, GET /users" -ForegroundColor DarkGray
Write-Host "  Swaps: POST /swaps, GET /swaps, POST /swaps/{id}/accept" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Frontend:" -ForegroundColor Yellow
Write-Host "  Home: http://localhost:5500/index.html" -ForegroundColor DarkGray
Write-Host "  Login: http://localhost:5500/login.html" -ForegroundColor DarkGray
Write-Host "  Register: http://localhost:5500/register.html" -ForegroundColor DarkGray
Write-Host "  Profile: http://localhost:5500/profile.html" -ForegroundColor DarkGray
Write-Host "  Swaps: http://localhost:5500/swap-requests.html" -ForegroundColor DarkGray
Write-Host "  API Tester: http://localhost:5500/api-test.html" -ForegroundColor DarkGray
Write-Host ""

Write-Host "❓ TROUBLESHOOTING" -ForegroundColor Cyan
Write-Host "================================"
Write-Host ""
Write-Host "Backend not starting:" -ForegroundColor Yellow
Write-Host "  1. Check MySQL is running" -ForegroundColor DarkGray
Write-Host "  2. Check port 8080 is not in use" -ForegroundColor DarkGray
Write-Host "  3. Review backend console output" -ForegroundColor DarkGray
Write-Host ""

Write-Host "CORS errors:" -ForegroundColor Yellow
Write-Host "  1. Check backend is running on http://localhost:8080" -ForegroundColor DarkGray
Write-Host "  2. Check frontend is on http://localhost:5500" -ForegroundColor DarkGray
Write-Host "  3. Review browser console for details" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Database errors:" -ForegroundColor Yellow
Write-Host "  1. Verify MySQL is running" -ForegroundColor DarkGray
Write-Host "  2. Check credentials in backend command" -ForegroundColor DarkGray
Write-Host "  3. Re-import schema if needed" -ForegroundColor DarkGray
Write-Host ""

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              🎉 Setup Complete! Ready for Testing               ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "👉 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Open http://localhost:5500/api-test.html in your browser" -ForegroundColor Green
Write-Host "  2. Use 'Quick Populate' to generate test data" -ForegroundColor Green
Write-Host "  3. Test the application at http://localhost:5500" -ForegroundColor Green
Write-Host ""
Write-Host "📧 Questions? Check FRONTEND_INTEGRATION.md for detailed documentation" -ForegroundColor Cyan
Write-Host ""
