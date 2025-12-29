/**
 * Sidebar JavaScript - Melhorado
 * Controla a abertura/fechamento da sidebar e submenus
 */

(function() {
    'use strict';

    // Elementos DOM
    const sidebar = document.getElementById('sidebar');
    const sidebarToggleInternal = document.getElementById('sidebarToggleInternal');
    const sidebarToggleExternal = document.getElementById('sidebarToggleExternal');
    const mainContent = document.getElementById('mainContent');
    const navLinks = document.querySelectorAll('.nav-link');
    const navToggles = document.querySelectorAll('.nav-toggle');
    let overlay = document.querySelector('.sidebar-overlay');
    
    // Criar overlay se não existir
    if (!overlay) {
        overlay = document.createElement('div');
        overlay.className = 'sidebar-overlay';
        document.body.appendChild(overlay);
    }

    // Estado
    let isMobile = window.innerWidth <= 1024;
    let sidebarOpen = false;

    // Inicialização
    function init() {
        setupEventListeners();
        setupResponsive();
        activateCurrentPage();
        updateTogglePosition();
        
        // NUNCA abre automaticamente - apenas quando o usuário clicar no botão
        // Sidebar sempre inicia fechada
        sidebarOpen = false;
        sidebar.classList.remove('open');
        updateTogglePosition();
    }

    // Fechar todos os submenus
    function closeAllSubmenus() {
        const allNavItems = document.querySelectorAll('.nav-item');
        allNavItems.forEach(item => {
            item.classList.remove('expanded');
        });
    }

    // Event Listeners
    function setupEventListeners() {
        // Toggle sidebar - botão interno
        if (sidebarToggleInternal) {
            sidebarToggleInternal.addEventListener('click', function(e) {
                e.stopPropagation();
                toggleSidebar();
            });
        }
        
        // Toggle sidebar - botão externo
        if (sidebarToggleExternal) {
            sidebarToggleExternal.addEventListener('click', function(e) {
                e.stopPropagation();
                toggleSidebar();
            });
        }

        // Toggle submenus
        navToggles.forEach(toggle => {
            toggle.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                const navItem = this.closest('.nav-item');
                if (navItem) {
                    toggleSubmenu(navItem);
                }
            });
        });

        // Fechar sidebar ao clicar no overlay
        overlay.addEventListener('click', function(e) {
            e.stopPropagation();
            e.preventDefault();
            if (sidebarOpen) {
                closeSidebar();
            }
        });
        
        // Fechar sidebar ao clicar fora (exceto na sidebar e no toggle)
        document.addEventListener('click', function(e) {
            // Não fecha se clicar na sidebar ou nos toggles
            if (sidebar && sidebar.contains(e.target)) {
                return;
            }
            if (sidebarToggleInternal && sidebarToggleInternal.contains(e.target)) {
                return;
            }
            if (sidebarToggleExternal && sidebarToggleExternal.contains(e.target)) {
                return;
            }
            
            // Fecha se sidebar estiver aberta
            if (sidebarOpen) {
                closeSidebar();
            }
        }, true);

        // Auto-rebater ao clicar em qualquer link de navegação
        navLinks.forEach(link => {
            if (!link.classList.contains('nav-toggle')) {
                link.addEventListener('click', function() {
                    // Fecha todos os submenus primeiro
                    closeAllSubmenus();
                    
                    // Reba a sidebar
                    if (sidebarOpen) {
                        setTimeout(() => {
                            closeSidebar();
                        }, 100);
                    }
                });
            }
        });

        // Resize handler
        window.addEventListener('resize', handleResize);

        // Fechar com ESC
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && sidebarOpen) {
                closeSidebar();
            }
        });
    }

    // Toggle sidebar
    function toggleSidebar() {
        if (sidebarOpen) {
            closeSidebar();
        } else {
            openSidebar();
        }
    }

    // Abrir sidebar
    function openSidebar() {
        sidebar.classList.add('open');
        sidebarOpen = true;
        updateTogglePosition();
        
        if (overlay) {
            if (isMobile) {
                document.body.style.overflow = 'hidden';
            }
            overlay.style.display = 'block';
            setTimeout(() => {
                overlay.style.opacity = isMobile ? '1' : '0.5';
                overlay.style.visibility = 'visible';
            }, 10);
        }
    }

    // Fechar sidebar
    function closeSidebar() {
        // Fecha todos os submenus antes de rebater
        closeAllSubmenus();
        
        sidebar.classList.remove('open');
        sidebarOpen = false;
        updateTogglePosition();
        
        if (overlay) {
            document.body.style.overflow = '';
            overlay.style.opacity = '0';
            overlay.style.visibility = 'hidden';
            setTimeout(() => {
                overlay.style.display = 'none';
            }, 200);
        }
    }

    // Atualizar posição do botão toggle
    function updateTogglePosition() {
        // A posição agora é controlada pelo CSS
        // Esta função pode ser usada para outras atualizações se necessário
    }

    // Toggle submenu
    function toggleSubmenu(navItem) {
        const isExpanded = navItem.classList.contains('expanded');
        const allNavItems = document.querySelectorAll('.nav-item');
        
        // Fecha todos os submenus
        allNavItems.forEach(item => {
            if (item !== navItem) {
                item.classList.remove('expanded');
            }
        });
        
        // Toggle do submenu atual
        if (isExpanded) {
            navItem.classList.remove('expanded');
        } else {
            navItem.classList.add('expanded');
            // Garante que sidebar está aberta
            if (!sidebarOpen) {
                openSidebar();
            }
        }
    }

    // Ativar página atual (sem expandir submenus)
    function activateCurrentPage() {
        const currentPath = window.location.pathname.toLowerCase();
        
        // Primeiro, fecha TODOS os submenus
        closeAllSubmenus();
        
        navLinks.forEach(link => {
            const href = link.getAttribute('href');
            if (href) {
                const linkPath = href.toLowerCase();
                // Remove classe active de todos
                link.classList.remove('active');
                
                // Ativa se o caminho corresponder (mas NÃO expande submenu)
                if (currentPath === linkPath || 
                    (linkPath !== '/' && currentPath.startsWith(linkPath))) {
                    link.classList.add('active');
                    // NÃO expande submenu automaticamente
                }
            }
        });
    }

    // Responsive
    function setupResponsive() {
        handleResize();
    }

    function handleResize() {
        const wasMobile = isMobile;
        isMobile = window.innerWidth <= 1024;
        
        if (wasMobile !== isMobile) {
            if (isMobile) {
                // Modo mobile: fecha sidebar
                closeSidebar();
            }
            // Em desktop, mantém o estado atual (não abre automaticamente)
            updateTogglePosition();
        } else {
            // Atualiza posição mesmo sem mudança de modo
            updateTogglePosition();
        }
    }

    // Inicializar quando DOM estiver pronto
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // Expor função para logout modal
    window.showLogoutModal = function() {
        if (confirm('Deseja realmente sair?')) {
            const logoutForm = document.getElementById('logoutForm');
            if (logoutForm) {
                logoutForm.submit();
            }
        }
    };

})();
