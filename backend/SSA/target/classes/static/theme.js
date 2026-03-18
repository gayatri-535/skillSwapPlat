// Theme Management System
class ThemeManager {
    constructor() {
        this.THEME_KEY = 'skillswap-theme';
        this.LIGHT_THEME = 'light';
        this.DARK_THEME = 'dark';
        this.init();
    }

    // Initialize theme on page load
    init() {
        const savedTheme = this.getSavedTheme();
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        const theme = savedTheme || (prefersDark ? this.DARK_THEME : this.LIGHT_THEME);
        this.applyTheme(theme);
    }

    // Get saved theme from localStorage
    getSavedTheme() {
        return localStorage.getItem(this.THEME_KEY);
    }

    // Save theme to localStorage
    saveTheme(theme) {
        localStorage.setItem(this.THEME_KEY, theme);
    }

    // Apply theme to document
    applyTheme(theme) {
        const html = document.documentElement;
        if (theme === this.DARK_THEME) {
            html.setAttribute('data-theme', 'dark');
        } else {
            html.removeAttribute('data-theme');
        }
        this.saveTheme(theme);
    }

    // Toggle between light and dark theme
    toggle() {
        const currentTheme = document.documentElement.getAttribute('data-theme') === 'dark' 
            ? this.DARK_THEME 
            : this.LIGHT_THEME;
        const newTheme = currentTheme === this.DARK_THEME ? this.LIGHT_THEME : this.DARK_THEME;
        this.applyTheme(newTheme);
        return newTheme;
    }

    // Get current theme
    getCurrentTheme() {
        return document.documentElement.getAttribute('data-theme') === 'dark' 
            ? this.DARK_THEME 
            : this.LIGHT_THEME;
    }

    // Update toggle button text/icon
    updateToggleButton() {
        const toggleBtn = document.getElementById('themeToggle');
        if (toggleBtn) {
            const theme = this.getCurrentTheme();
            toggleBtn.textContent = theme === 'dark' ? '☀️ Light' : '🌙 Dark';
            toggleBtn.title = `Switch to ${theme === 'dark' ? 'Light' : 'Dark'} Theme`;
        }
    }
}

// Initialize theme manager
const themeManager = new ThemeManager();

// Setup toggle button click handler
document.addEventListener('DOMContentLoaded', function() {
    const toggleBtn = document.getElementById('themeToggle');
    if (toggleBtn) {
        toggleBtn.addEventListener('click', function() {
            themeManager.toggle();
            themeManager.updateToggleButton();
        });
        themeManager.updateToggleButton();
    }
});
