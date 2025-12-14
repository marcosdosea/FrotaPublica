/**
 * Theme Toggle - Alternância entre tema claro e escuro
 */

(function() {
    'use strict';

    const themeToggle = document.getElementById('themeToggle');
    const themeToggleIcon = document.getElementById('themeToggleIcon');

    // Carregar tema salvo
    function loadTheme() {
        const savedTheme = localStorage.getItem('theme') || 'light';
        document.documentElement.setAttribute('data-theme', savedTheme);
        updateThemeIcon(savedTheme);
    }

    // Alternar tema
    function toggleTheme() {
        const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
        
        document.documentElement.setAttribute('data-theme', newTheme);
        localStorage.setItem('theme', newTheme);
        updateThemeIcon(newTheme);
    }

    // Atualizar ícone do tema
    function updateThemeIcon(theme) {
        if (!themeToggleIcon) return;

        const icon = themeToggleIcon.querySelector('i');
        if (!icon) return;

        if (theme === 'dark') {
            icon.className = 'fas fa-sun';
            if (themeToggle) {
                themeToggle.setAttribute('title', 'Alternar para tema claro');
            }
        } else {
            icon.className = 'fas fa-moon';
            if (themeToggle) {
                themeToggle.setAttribute('title', 'Alternar para tema escuro');
            }
        }
    }

    // Inicializar
    function init() {
        loadTheme();
        
        if (themeToggle) {
            themeToggle.addEventListener('click', toggleTheme);
        }
    }

    // Inicializar quando DOM estiver pronto
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();

