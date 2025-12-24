// SkillSwap API Client
const API_BASE_URL = 'http://localhost:8080/api';

// Session storage for current user
const sessionStorage_user = {
    get current() {
        const data = sessionStorage.getItem('skillswap_user');
        return data ? JSON.parse(data) : null;
    },
    set current(user) {
        if (user) {
            sessionStorage.setItem('skillswap_user', JSON.stringify(user));
        } else {
            sessionStorage.removeItem('skillswap_user');
        }
    },
    clear() {
        sessionStorage.removeItem('skillswap_user');
    }
};

// API Client class
class SkillSwapAPI {
    static async register(userData) {
        try {
            const response = await fetch(`${API_BASE_URL}/users/register`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(userData)
            });
            const data = await response.text();
            return {
                success: response.ok,
                status: response.status,
                message: data,
                data: response.ok ? userData : null
            };
        } catch (error) {
            return { success: false, error: error.message };
        }
    }

    static async login(email, password) {
        try {
            const response = await fetch(`${API_BASE_URL}/users/login?email=${encodeURIComponent(email)}&password=${encodeURIComponent(password)}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' }
            });
            
            if (response.ok) {
                const user = await response.json();
                sessionStorage_user.current = user;
                return { success: true, user };
            } else {
                return { success: false, message: 'Invalid email or password' };
            }
        } catch (error) {
            return { success: false, error: error.message };
        }
    }

    static async logout() {
        sessionStorage_user.clear();
        return { success: true };
    }

    static async listUsers() {
        try {
            const response = await fetch(`${API_BASE_URL}/users`, {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' }
            });
            if (response.ok) {
                const users = await response.json();
                return { success: true, users };
            } else {
                return { success: false, message: 'Failed to fetch users' };
            }
        } catch (error) {
            return { success: false, error: error.message };
        }
    }

    static async getUserByEmail(email) {
        try {
            const response = await fetch(`${API_BASE_URL}/users/${encodeURIComponent(email)}`, {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' }
            });
            if (response.ok) {
                const user = await response.json();
                return { success: true, user };
            } else {
                return { success: false, message: 'User not found' };
            }
        } catch (error) {
            return { success: false, error: error.message };
        }
    }

    static async createSwap(requesterId, receiverId, requestedSkill, offeredSkill) {
        try {
            const response = await fetch(`${API_BASE_URL}/swaps`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    requesterId,
                    receiverId,
                    requestedSkill,
                    offeredSkill,
                    status: 'pending'
                })
            });
            const message = await response.text();
            return {
                success: response.ok,
                status: response.status,
                message
            };
        } catch (error) {
            return { success: false, error: error.message };
        }
    }

    static async listSwaps() {
        try {
            const response = await fetch(`${API_BASE_URL}/swaps`, {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' }
            });
            if (response.ok) {
                const swaps = await response.json();
                return { success: true, swaps };
            } else {
                return { success: false, message: 'Failed to fetch swaps' };
            }
        } catch (error) {
            return { success: false, error: error.message };
        }
    }

    static async listUserSwaps(userId) {
        try {
            const response = await fetch(`${API_BASE_URL}/swaps/user/${userId}`, {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' }
            });
            if (response.ok) {
                const swaps = await response.json();
                return { success: true, swaps };
            } else {
                return { success: false, message: 'Failed to fetch user swaps' };
            }
        } catch (error) {
            return { success: false, error: error.message };
        }
    }

    static async acceptSwap(swapId) {
        try {
            const response = await fetch(`${API_BASE_URL}/swaps/${swapId}/accept`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' }
            });
            const message = await response.text();
            return {
                success: response.ok,
                status: response.status,
                message
            };
        } catch (error) {
            return { success: false, error: error.message };
        }
    }

    static async cancelSwap(swapId) {
        try {
            const response = await fetch(`${API_BASE_URL}/swaps/${swapId}/cancel`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' }
            });
            const message = await response.text();
            return {
                success: response.ok,
                status: response.status,
                message
            };
        } catch (error) {
            return { success: false, error: error.message };
        }
    }

    static isLoggedIn() {
        return sessionStorage_user.current !== null;
    }

    static getCurrentUser() {
        return sessionStorage_user.current;
    }
}

// Utility functions
function showMessage(elementId, message, isSuccess = true) {
    const element = document.getElementById(elementId);
    if (element) {
        element.textContent = message;
        element.style.color = isSuccess ? 'green' : 'red';
        element.style.marginTop = '10px';
    }
}

function showLoading(elementId, show = true) {
    const element = document.getElementById(elementId);
    if (element) {
        element.textContent = show ? 'Loading...' : '';
    }
}
