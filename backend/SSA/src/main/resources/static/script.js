// Shared UX enhancements for the SkillSwap PWA
console.log('SkillSwap UI Enhancements Loaded');

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
const SPLASH_DURATION_MS = 850;

async function checkBackendHealth() {
    if (!navigator.onLine) {
        return false;
    }

    try {
        const response = await fetch(`${API_BASE}/users`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' },
            cache: 'no-store'
        });
        console.log('Backend is healthy:', response.ok);
        return response.ok;
    } catch (error) {
        console.warn('Backend not available:', error.message);
        return false;
    }
}

function createSplashElement() {
    const splash = document.createElement('div');
    splash.className = 'app-splash';
    splash.innerHTML = `
        <div class="app-splash__logo" aria-hidden="true">SS</div>
        <div class="app-splash__brand">SkillSwap</div>
        <div class="app-splash__tagline">Learn. Teach. Grow.</div>
    `;
    return splash;
}

function showStartupSplash() {
    if (document.body.dataset.disableSplash === 'true') {
        return;
    }
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        return;
    }

    const splash = createSplashElement();
    document.body.appendChild(splash);

    window.setTimeout(() => {
        splash.classList.add('app-splash--hide');
        window.setTimeout(() => {
            splash.remove();
        }, 500);
    }, SPLASH_DURATION_MS);
}

function enhancePasswordFields() {
    const passwordInputs = document.querySelectorAll('input[type="password"]');

    passwordInputs.forEach((input, index) => {
        if (input.dataset.toggleReady === 'true') {
            return;
        }

        const wrapper = document.createElement('div');
        wrapper.className = 'password-field';

        const parent = input.parentNode;
        parent.insertBefore(wrapper, input);
        wrapper.appendChild(input);

        const toggleBtn = document.createElement('button');
        toggleBtn.type = 'button';
        toggleBtn.className = 'password-toggle';
        toggleBtn.textContent = 'Show';
        toggleBtn.setAttribute('aria-label', 'Show password');
        toggleBtn.setAttribute('aria-pressed', 'false');
        toggleBtn.id = `password-toggle-${index}`;

        toggleBtn.addEventListener('click', () => {
            const reveal = input.type === 'password';
            input.type = reveal ? 'text' : 'password';
            toggleBtn.textContent = reveal ? 'Hide' : 'Show';
            toggleBtn.setAttribute('aria-label', reveal ? 'Hide password' : 'Show password');
            toggleBtn.setAttribute('aria-pressed', reveal ? 'true' : 'false');
        });

        wrapper.appendChild(toggleBtn);
        input.dataset.toggleReady = 'true';
    });
}

function syncThemeColorMeta() {
    let metaTheme = document.querySelector('meta[name="theme-color"]');
    if (!metaTheme) {
        metaTheme = document.createElement('meta');
        metaTheme.setAttribute('name', 'theme-color');
        document.head.appendChild(metaTheme);
    }

    const isDarkTheme = document.documentElement.getAttribute('data-theme') === 'dark';
    metaTheme.setAttribute('content', isDarkTheme ? '#081328' : '#0f766e');
}

function wireThemeObserver() {
    syncThemeColorMeta();

    const observer = new MutationObserver(() => {
        syncThemeColorMeta();
    });

    observer.observe(document.documentElement, {
        attributes: true,
        attributeFilter: ['data-theme']
    });
}

function enableSmoothSectionNav() {
    const hashLinks = document.querySelectorAll('a[href^="#"]');
    hashLinks.forEach((link) => {
        link.addEventListener('click', (event) => {
            const targetSelector = link.getAttribute('href');
            if (!targetSelector || targetSelector.length < 2) {
                return;
            }

            const targetElement = document.querySelector(targetSelector);
            if (!targetElement) {
                return;
            }

            event.preventDefault();
            targetElement.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        });
    });
}

document.addEventListener('DOMContentLoaded', () => {
    showStartupSplash();
    enhancePasswordFields();
    wireThemeObserver();
    enableSmoothSectionNav();
    checkBackendHealth();
});
