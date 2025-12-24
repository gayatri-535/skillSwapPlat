#!/usr/bin/env pwsh

# Test API endpoints
Write-Host "Testing SkillSwap Backend API" -ForegroundColor Green

# Test 1: Register a user
Write-Host "`n--- Test 1: Register a user ---"
$registerJson = @{
    name = "Alice Johnson"
    email = "alice@example.com"
    password = "securepass123"
    location = "San Francisco"
    availability = "weekdays"
} | ConvertTo-Json

Write-Host "Sending: $registerJson"
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/users/register" `
        -Method POST `
        -ContentType "application/json" `
        -Body $registerJson -ErrorAction Stop
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: List all users
Write-Host "`n--- Test 2: List all users ---"
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/users" `
        -Method GET `
        -ContentType "application/json" -ErrorAction Stop
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content | ConvertFrom-Json | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Login with correct credentials
Write-Host "`n--- Test 3: Login with correct credentials ---"
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/users/login?email=alice@example.com&password=securepass123" `
        -Method POST `
        -ContentType "application/json" -ErrorAction Stop
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content | ConvertFrom-Json | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Login with incorrect credentials
Write-Host "`n--- Test 4: Login with incorrect credentials ---"
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/users/login?email=alice@example.com&password=wrongpassword" `
        -Method POST `
        -ContentType "application/json" -ErrorAction Stop
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    Write-Host "Response: $($_.Exception.Response.StatusDescription)" -ForegroundColor Yellow
}

# Test 5: Create a swap request
Write-Host "`n--- Test 5: Create a swap request ---"
$swapJson = @{
    requesterId = 1
    receiverId = 2
    requestedSkill = "Python"
    offeredSkill = "JavaScript"
    status = "pending"
} | ConvertTo-Json

Write-Host "Sending: $swapJson"
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/swaps" `
        -Method POST `
        -ContentType "application/json" `
        -Body $swapJson -ErrorAction Stop
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n--- All tests completed ---" -ForegroundColor Green
