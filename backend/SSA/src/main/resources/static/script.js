// Shared UX enhancements for the SkillSwap PWA
console.log('SkillSwap UI Enhancements Loaded');

function resolveApiBase() {
    if (window.SkillSwapAPI && typeof window.SkillSwapAPI.getApiCandidates === 'function') {
        const candidates = window.SkillSwapAPI.getApiCandidates();
        if (candidates.length > 0) {
            return candidates[0];
        }
    }

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
const INSTALL_DISMISS_KEY = 'skillswap-install-dismissed-at';
const INSTALL_COOLDOWN_MS = 24 * 60 * 60 * 1000;

let deferredInstallPrompt = null;

async function checkBackendHealth() {
    if (!navigator.onLine) {
        renderBackendStatus(false, 'Offline mode');
        return false;
    }

    try {
        if (window.SkillSwapAPI && typeof window.SkillSwapAPI.probeBackends === 'function') {
            const probe = await window.SkillSwapAPI.probeBackends();
            renderBackendStatus(probe.ok, probe.ok ? `Connected: ${probe.base}` : 'Backend unavailable');
            return probe.ok;
        }

        const response = await fetch(`${API_BASE}/users`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' },
            cache: 'no-store'
        });
        renderBackendStatus(response.ok, response.ok ? `Connected: ${API_BASE}` : 'Backend unavailable');
        console.log('Backend is healthy:', response.ok);
        return response.ok;
    } catch (error) {
        console.warn('Backend not available:', error.message);
        renderBackendStatus(false, 'Backend unavailable');
        return false;
    }
}

function ensureBackendStatusElement() {
    let status = document.getElementById('backendStatusPill');
    if (status) {
        return status;
    }

    const nav = document.querySelector('nav');
    if (!nav) {
        return null;
    }

    status = document.createElement('span');
    status.id = 'backendStatusPill';
    status.style.marginLeft = 'auto';
    status.style.padding = '6px 10px';
    status.style.borderRadius = '999px';
    status.style.fontSize = '12px';
    status.style.fontWeight = '600';
    status.style.border = '1px solid var(--border-color)';
    status.style.background = 'var(--bg-elevated)';
    status.style.color = 'var(--text-secondary)';
    status.textContent = 'Checking backend...';
    nav.appendChild(status);
    return status;
}

function renderBackendStatus(isHealthy, message) {
    const pill = ensureBackendStatusElement();
    if (!pill) {
        return;
    }

    if (isHealthy) {
        pill.style.background = 'rgba(15, 118, 110, 0.2)';
        pill.style.borderColor = 'rgba(15, 118, 110, 0.45)';
        pill.style.color = '#2dd4bf';
        pill.textContent = 'Backend online';
        pill.title = message || 'Connected';
    } else {
        pill.style.background = 'rgba(239, 68, 68, 0.15)';
        pill.style.borderColor = 'rgba(239, 68, 68, 0.45)';
        pill.style.color = '#fda4af';
        pill.textContent = 'Backend offline';
        pill.title = message || 'Unavailable';
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

function isStandaloneMode() {
    return window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone === true;
}

function isIosSafari() {
    const ua = window.navigator.userAgent.toLowerCase();
    const isIos = /iphone|ipad|ipod/.test(ua);
    const isSafari = /safari/.test(ua) && !/crios|fxios|edgios|opr\//.test(ua);
    return isIos && isSafari;
}

function wasInstallBannerDismissedRecently() {
    const lastDismissed = Number(window.localStorage.getItem(INSTALL_DISMISS_KEY) || '0');
    if (!lastDismissed) {
        return false;
    }
    return Date.now() - lastDismissed < INSTALL_COOLDOWN_MS;
}

function ensureInstallBannerElement() {
    let banner = document.getElementById('pwaInstallBanner');
    if (banner) {
        return banner;
    }

    banner = document.createElement('div');
    banner.id = 'pwaInstallBanner';
    banner.className = 'install-banner';
    document.body.appendChild(banner);
    return banner;
}

function hideInstallBanner() {
    const banner = document.getElementById('pwaInstallBanner');
    if (!banner) {
        return;
    }
    banner.classList.remove('install-banner--show');
    window.setTimeout(() => {
        banner.remove();
    }, 220);
}

function markInstallBannerDismissed() {
    window.localStorage.setItem(INSTALL_DISMISS_KEY, String(Date.now()));
}

function showInstallBanner(options = {}) {
    if (isStandaloneMode() || wasInstallBannerDismissedRecently()) {
        return;
    }

    const { iosHint = false } = options;
    const banner = ensureInstallBannerElement();

    if (iosHint) {
        banner.innerHTML = `
            <div class="install-banner__text">Install SkillSwap: tap <strong>Share</strong> and choose <strong>Add to Home Screen</strong>.</div>
            <div class="install-banner__actions">
                <button type="button" class="install-banner__btn install-banner__btn--ghost" id="installDismissBtn">Got it</button>
            </div>
        `;
    } else {
        banner.innerHTML = `
            <div class="install-banner__text">Install SkillSwap for faster access and app-like full-screen mode.</div>
            <div class="install-banner__actions">
                <button type="button" class="install-banner__btn" id="installNowBtn">Install</button>
                <button type="button" class="install-banner__btn install-banner__btn--ghost" id="installDismissBtn">Later</button>
            </div>
        `;

        const installNowBtn = banner.querySelector('#installNowBtn');
        if (installNowBtn) {
            installNowBtn.addEventListener('click', async () => {
                if (!deferredInstallPrompt) {
                    return;
                }

                deferredInstallPrompt.prompt();
                const choice = await deferredInstallPrompt.userChoice;
                deferredInstallPrompt = null;

                if (choice.outcome === 'accepted') {
                    window.localStorage.removeItem(INSTALL_DISMISS_KEY);
                    hideInstallBanner();
                } else {
                    markInstallBannerDismissed();
                    hideInstallBanner();
                }
            });
        }
    }

    const dismissBtn = banner.querySelector('#installDismissBtn');
    if (dismissBtn) {
        dismissBtn.addEventListener('click', () => {
            markInstallBannerDismissed();
            hideInstallBanner();
        });
    }

    window.requestAnimationFrame(() => {
        banner.classList.add('install-banner--show');
    });
}

function setupInstallExperience() {
    window.addEventListener('beforeinstallprompt', (event) => {
        event.preventDefault();
        deferredInstallPrompt = event;
        showInstallBanner();
    });

    window.addEventListener('appinstalled', () => {
        deferredInstallPrompt = null;
        window.localStorage.removeItem(INSTALL_DISMISS_KEY);
        hideInstallBanner();
    });

    if (isIosSafari() && !isStandaloneMode()) {
        window.setTimeout(() => {
            showInstallBanner({ iosHint: true });
        }, 1200);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    showStartupSplash();
    enhancePasswordFields();
    wireThemeObserver();
    enableSmoothSectionNav();
    setupInstallExperience();
    checkBackendHealth();
});
