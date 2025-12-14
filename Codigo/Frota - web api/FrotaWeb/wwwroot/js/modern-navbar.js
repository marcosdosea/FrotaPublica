/**
 * MODERN NAVBAR - FROTA PÚBLICA
 * JavaScript para controlar a navbar moderna inspirada na Apple
 */

class ModernNavbar {
  constructor() {
    this.sidebar = document.querySelector('.modern-sidebar');
    this.mainContent = document.querySelector('.main-content');
    this.toggleBtn = document.querySelector('.sidebar-toggle');
    this.themeToggle = document.querySelector('.theme-toggle');
    this.overlay = document.querySelector('.sidebar-overlay');
    this.mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
    
    this.isCollapsed = false;
    this.isHidden = false;
    this.isMobile = window.innerWidth <= 1024;
    
    this.init();
  }

  init() {
    this.setupEventListeners();
    this.loadTheme();
    this.setupResponsive();
    this.activateCurrentPage();
  }

  setupEventListeners() {
    // Toggle sidebar
    if (this.toggleBtn) {
      this.toggleBtn.addEventListener('click', () => this.toggleSidebar());
    }

    // Theme toggle
    if (this.themeToggle) {
      this.themeToggle.addEventListener('click', () => this.toggleTheme());
    }

    // Mobile menu toggle
    if (this.mobileMenuToggle) {
      this.mobileMenuToggle.addEventListener('click', () => this.toggleMobileMenu());
    }

    // Overlay click (mobile)
    if (this.overlay) {
      this.overlay.addEventListener('click', () => this.closeMobileMenu());
    }

    // Window resize
    window.addEventListener('resize', () => this.handleResize());

    // Keyboard shortcuts
    document.addEventListener('keydown', (e) => this.handleKeyboard(e));

    // Navigation links
    this.setupNavigationLinks();
  }

  setupNavigationLinks() {
    const navLinks = document.querySelectorAll('.nav-link');
    
    navLinks.forEach(link => {
      // Handle submenu toggles
      if (link.dataset.submenu) {
        link.addEventListener('click', (e) => {
          e.preventDefault();
          this.toggleSubmenu(link.dataset.submenu);
        });
      }

      // Handle regular navigation
      if (!link.dataset.submenu && !link.dataset.noNavigate) {
        link.addEventListener('click', (e) => {
          // Add loading state
          this.setLinkLoading(link, true);
          
          // Remove loading state after navigation
          setTimeout(() => {
            this.setLinkLoading(link, false);
          }, 1000);
        });
      }
    });
  }

  toggleSidebar() {
    if (this.isMobile) {
      this.toggleMobileMenu();
      return;
    }

    if (this.isHidden) {
      this.showSidebar();
    } else if (this.isCollapsed) {
      this.expandSidebar();
    } else {
      this.collapseSidebar();
    }
  }

  collapseSidebar() {
    this.sidebar.classList.add('collapsed');
    this.mainContent.classList.add('sidebar-collapsed');
    this.isCollapsed = true;
    this.saveSidebarState();
  }

  expandSidebar() {
    this.sidebar.classList.remove('collapsed');
    this.mainContent.classList.remove('sidebar-collapsed');
    this.isCollapsed = false;
    this.saveSidebarState();
  }

  hideSidebar() {
    this.sidebar.classList.add('hidden');
    this.mainContent.classList.add('sidebar-hidden');
    this.isHidden = true;
    this.saveSidebarState();
  }

  showSidebar() {
    this.sidebar.classList.remove('hidden');
    this.mainContent.classList.remove('sidebar-hidden');
    this.isHidden = false;
    this.saveSidebarState();
  }

  toggleMobileMenu() {
    if (this.sidebar.classList.contains('mobile-open')) {
      this.closeMobileMenu();
    } else {
      this.openMobileMenu();
    }
  }

  openMobileMenu() {
    this.sidebar.classList.add('mobile-open');
    this.overlay.classList.add('active');
    document.body.style.overflow = 'hidden';
  }

  closeMobileMenu() {
    this.sidebar.classList.remove('mobile-open');
    this.overlay.classList.remove('active');
    document.body.style.overflow = '';
  }

  toggleSubmenu(submenuId) {
    const submenu = document.querySelector(`#${submenuId}`);
    const isOpen = submenu.classList.contains('open');
    
    // Close all other submenus
    document.querySelectorAll('.nav-submenu').forEach(menu => {
      menu.classList.remove('open');
    });

    // Toggle current submenu
    if (!isOpen) {
      submenu.classList.add('open');
    }

    // Ensure sidebar is expanded on mobile
    if (this.isMobile && !this.sidebar.classList.contains('mobile-open')) {
      this.openMobileMenu();
    }
  }

  toggleTheme() {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    
    // Update theme toggle icon
    this.updateThemeIcon(newTheme);
  }

  updateThemeIcon(theme) {
    if (!this.themeToggle) return;

    const icon = this.themeToggle.querySelector('svg');
    if (!icon) return;

    if (theme === 'dark') {
      icon.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
        </svg>
      `;
    } else {
      icon.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
        </svg>
      `;
    }
  }

  loadTheme() {
    const savedTheme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);
    this.updateThemeIcon(savedTheme);
  }

  saveSidebarState() {
    const state = {
      collapsed: this.isCollapsed,
      hidden: this.isHidden
    };
    localStorage.setItem('sidebarState', JSON.stringify(state));
  }

  loadSidebarState() {
    const saved = localStorage.getItem('sidebarState');
    if (saved) {
      const state = JSON.parse(saved);
      this.isCollapsed = state.collapsed;
      this.isHidden = state.hidden;
      
      if (this.isHidden) {
        this.hideSidebar();
      } else if (this.isCollapsed) {
        this.collapseSidebar();
      }
    }
  }

  setupResponsive() {
    this.handleResize();
    this.loadSidebarState();
  }

  handleResize() {
    const wasMobile = this.isMobile;
    this.isMobile = window.innerWidth <= 1024;

    if (wasMobile !== this.isMobile) {
      if (this.isMobile) {
        // Switch to mobile mode
        this.closeMobileMenu();
        this.sidebar.classList.remove('collapsed');
        this.mainContent.classList.remove('sidebar-collapsed');
      } else {
        // Switch to desktop mode
        this.closeMobileMenu();
        this.loadSidebarState();
      }
    }
  }

  handleKeyboard(e) {
    // Ctrl/Cmd + B to toggle sidebar
    if ((e.ctrlKey || e.metaKey) && e.key === 'b') {
      e.preventDefault();
      this.toggleSidebar();
    }

    // Escape to close mobile menu
    if (e.key === 'Escape' && this.isMobile) {
      this.closeMobileMenu();
    }

    // Ctrl/Cmd + K to toggle theme
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
      e.preventDefault();
      this.toggleTheme();
    }
  }

  activateCurrentPage() {
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('.nav-link');
    
    navLinks.forEach(link => {
      const href = link.getAttribute('href');
      if (href && currentPath.includes(href)) {
        link.classList.add('active');
        
        // If it's in a submenu, open the submenu
        const submenu = link.closest('.nav-submenu');
        if (submenu) {
          submenu.classList.add('open');
        }
      } else {
        link.classList.remove('active');
      }
    });
  }

  setLinkLoading(link, loading) {
    if (loading) {
      link.classList.add('loading');
    } else {
      link.classList.remove('loading');
    }
  }

  // Public methods for external use
  showNotification(linkId, count = 1) {
    const link = document.querySelector(`[data-link="${linkId}"]`);
    if (!link) return;

    let indicator = link.querySelector('.notification-indicator');
    if (!indicator) {
      indicator = document.createElement('div');
      indicator.className = 'notification-indicator';
      link.appendChild(indicator);
    }

    indicator.textContent = count > 99 ? '99+' : count;
    indicator.style.display = count > 0 ? 'flex' : 'none';
  }

  hideNotification(linkId) {
    this.showNotification(linkId, 0);
  }

  // Method to update user info
  updateUserInfo(userData) {
    const userAvatar = document.querySelector('.user-avatar');
    const userName = document.querySelector('.user-name');
    const userRole = document.querySelector('.user-role');

    if (userAvatar && userData.avatar) {
      userAvatar.style.backgroundImage = `url(${userData.avatar})`;
      userAvatar.style.backgroundSize = 'cover';
      userAvatar.style.backgroundPosition = 'center';
    }

    if (userName && userData.name) {
      userName.textContent = userData.name;
    }

    if (userRole && userData.role) {
      userRole.textContent = userData.role;
    }
  }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  window.modernNavbar = new ModernNavbar();
});

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = ModernNavbar;
}
