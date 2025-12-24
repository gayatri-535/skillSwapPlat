// Main script file - Additional functionality for the SkillSwap platform
console.log("Skill Swap Platform - Frontend Initialized");

// Check if backend is available
async function checkBackendHealth() {
    try {
        const response = await fetch('http://localhost:8080/api/users', {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        });
        console.log('Backend is healthy:', response.ok);
        return response.ok;
    } catch (error) {
        console.warn('Backend not available:', error.message);
        console.warn('Make sure the backend is running on http://localhost:8080');
        return false;
    }
}

// Run health check on page load
document.addEventListener('DOMContentLoaded', function() {
    checkBackendHealth();
});

// Additional utility functions can be added here as needed
