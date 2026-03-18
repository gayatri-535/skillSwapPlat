// SkillSwap API Client
// Resolve API base URL with fallback candidates for local/mobile/dev setups.
function normalizeApiBaseUrl(value) {
    if (!value) {
        return null;
    }

    const trimmed = String(value).trim().replace(/\/+$/, '');
    if (!trimmed) {
        return null;
    }

    return trimmed.endsWith('/api') ? trimmed : `${trimmed}/api`;
}

function getApiBaseOverride() {
    try {
        const params = new URLSearchParams(window.location.search);
        const queryOverride = params.get('apiBase');
        if (queryOverride) {
            localStorage.setItem('skillswap_api_base', queryOverride);
            return queryOverride;
        }
        return localStorage.getItem('skillswap_api_base');
    } catch (e) {
        return null;
    }
}

function normalizeHostForUrl(hostname) {
    return hostname.includes(':') && !hostname.startsWith('[')
        ? `[${hostname}]`
        : hostname;
}

function isPrivateOrLocalHost(hostname) {
    return hostname === 'localhost'
        || hostname === '127.0.0.1'
        || hostname === '::1'
        || hostname === '[::1]'
        || /^10\./.test(hostname)
        || /^192\.168\./.test(hostname)
        || /^172\.(1[6-9]|2\d|3[0-1])\./.test(hostname);
}

// Production backend used by the deployed Vercel/PWA frontend.
const DEPLOYED_BACKEND_BASE = 'https://skillswapplat.onrender.com';

const API_BASE_CANDIDATES = (() => {
    const { protocol, hostname, port, origin } = window.location;
    const candidates = [];

    const addCandidate = (value) => {
        const normalized = normalizeApiBaseUrl(value);
        if (normalized && !candidates.includes(normalized)) {
            candidates.push(normalized);
        }
    };

    const override = getApiBaseOverride();
    if (override) {
        addCandidate(override);
    }

    // When running from a public host (Vercel/custom domain), prefer deployed backend.
    if (hostname && !isPrivateOrLocalHost(hostname) && hostname !== '10.0.2.2') {
        addCandidate(DEPLOYED_BACKEND_BASE);
    }

    if (protocol === 'file:' || !hostname) {
        addCandidate('http://localhost:8080');
        addCandidate('http://127.0.0.1:8080');
        return candidates;
    }

    if (hostname === '10.0.2.2') {
        addCandidate('http://10.0.2.2:8080');
    }

    const normalizedHost = normalizeHostForUrl(hostname);
    const sameHost8080 = `${protocol}//${normalizedHost}:8080`;

    // Default same-origin API first.
    addCandidate(origin);

    // If frontend runs on any non-8080 port, try backend on same host:8080.
    if (port && port !== '8080') {
        addCandidate(sameHost8080);
    }

    // If opened from a local/private host without explicit port, keep 8080 fallback.
    if (!port && isPrivateOrLocalHost(hostname)) {
        addCandidate(sameHost8080);
    }

    // Last-resort local machine fallbacks.
    addCandidate('http://localhost:8080');
    addCandidate('http://127.0.0.1:8080');

    return candidates;
})();

const API_BASE_URL = API_BASE_CANDIDATES[0];

async function apiFetch(path, options = {}) {
    const endpointPath = path.startsWith('/') ? path : `/${path}`;
    let lastError = null;

    for (let i = 0; i < API_BASE_CANDIDATES.length; i++) {
        const base = API_BASE_CANDIDATES[i];
        try {
            const response = await fetch(`${base}${endpointPath}`, options);

            const contentType = (response.headers.get('content-type') || '').toLowerCase();
            const shouldFallback = (
                i < API_BASE_CANDIDATES.length - 1
                && response.status === 404
                && contentType.includes('text/html')
            );

            if (shouldFallback) {
                continue;
            }

            return response;
        } catch (error) {
            lastError = error;
        }
    }

    if (lastError) {
        throw lastError;
    }

    throw new Error('Unable to reach SkillSwap API');
}

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
            const response = await apiFetch('/users/register', {
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
            const response = await apiFetch(`/users/login?email=${encodeURIComponent(email)}&password=${encodeURIComponent(password)}`, {
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
            const response = await apiFetch('/users', {
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
            const response = await apiFetch(`/users/${encodeURIComponent(email)}`, {
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
            const response = await apiFetch('/swaps', {
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
            const response = await apiFetch('/swaps', {
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
            const response = await apiFetch(`/swaps/user/${userId}`, {
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
            const response = await apiFetch(`/swaps/${swapId}/accept`, {
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
            const response = await apiFetch(`/swaps/${swapId}/cancel`, {
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

