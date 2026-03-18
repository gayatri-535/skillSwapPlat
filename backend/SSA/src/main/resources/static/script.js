// Main script file - Additional functionality for the SkillSwap platform
console.log("Skill Swap Platform - Frontend Initialized");

function resolveApiBase() {
    const { protocol, hostname, port, origin } = window.location;

    if (protocol === 'file:' || !hostname) {
        return 'http://localhost:8080/api';
    }
    if (hostname === '10.0.2.2') {
        return 'http://10.0.2.2:8080/api';
    }

    const normalizedHost = hostname.includes(':') ? `[${hostname}]` : hostname;
    if (port === '5500' || port === '3000') {
        return `http://${normalizedHost}:8080/api`;
    }

    return `${origin}/api`;
}

const API_BASE = resolveApiBase();

// Check if backend is available
async function checkBackendHealth() {
    try {
        const response = await fetch(`${API_BASE}/users`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        });
        console.log('Backend is healthy:', response.ok);
        return response.ok;
    } catch (error) {
        console.warn('Backend not available:', error.message);
        console.warn('Make sure the backend is running and reachable from:', API_BASE);
        return false;
    }
}

// Run health check on page load
document.addEventListener('DOMContentLoaded', function() {
    checkBackendHealth();
});

// Additional utility functions can be added here as needed
