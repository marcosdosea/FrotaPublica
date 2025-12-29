/**
 * MODERN UI - FROTA PÚBLICA
 * JavaScript para funcionalidades modernas de UI
 */

class ModernUI {
  constructor() {
    this.init();
  }

  init() {
    this.setupAnimations();
    this.setupInteractions();
    this.setupFormEnhancements();
    this.setupTableEnhancements();
    this.setupNotifications();
    this.setupKeyboardShortcuts();
  }

  // ========================================
  // ANIMAÇÕES E TRANSITIONS
  // ========================================
  setupAnimations() {
    // Intersection Observer para animações de entrada
    const observerOptions = {
      threshold: 0.1,
      rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('animate-fade-in');
          observer.unobserve(entry.target);
        }
      });
    }, observerOptions);

    // Observar elementos que devem ser animados
    document.querySelectorAll('.stat-card, .reminder-card, .quick-action-card, .form-card, .table-card').forEach(el => {
      observer.observe(el);
    });

    // Animações de hover suaves
    document.querySelectorAll('.card, .btn, .nav-link').forEach(el => {
      el.addEventListener('mouseenter', this.addHoverEffect.bind(this));
      el.addEventListener('mouseleave', this.removeHoverEffect.bind(this));
    });
  }

  addHoverEffect(event) {
    const element = event.currentTarget;
    element.style.transform = 'translateY(-2px)';
    element.style.transition = 'transform 0.2s ease-out';
  }

  removeHoverEffect(event) {
    const element = event.currentTarget;
    element.style.transform = 'translateY(0)';
  }

  // ========================================
  // INTERAÇÕES E FEEDBACK
  // ========================================
  setupInteractions() {
    // Feedback visual para cliques
    document.addEventListener('click', (e) => {
      if (e.target.matches('.btn, .nav-link, .table-action-btn, .quick-action-card')) {
        this.createRippleEffect(e);
      }
    });

    // Loading states
    document.addEventListener('submit', (e) => {
      if (e.target.matches('form')) {
        this.showFormLoading(e.target);
      }
    });

    // Smooth scrolling para links internos
    document.querySelectorAll('a[href^="#"]').forEach(link => {
      link.addEventListener('click', (e) => {
        e.preventDefault();
        const target = document.querySelector(link.getAttribute('href'));
        if (target) {
          target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
      });
    });
  }

  createRippleEffect(event) {
    const element = event.currentTarget;
    const rect = element.getBoundingClientRect();
    const size = Math.max(rect.width, rect.height);
    const x = event.clientX - rect.left - size / 2;
    const y = event.clientY - rect.top - size / 2;

    const ripple = document.createElement('span');
    ripple.style.cssText = `
      position: absolute;
      width: ${size}px;
      height: ${size}px;
      left: ${x}px;
      top: ${y}px;
      background: rgba(255, 255, 255, 0.3);
      border-radius: 50%;
      transform: scale(0);
      animation: ripple 0.6s linear;
      pointer-events: none;
    `;

    element.style.position = 'relative';
    element.style.overflow = 'hidden';
    element.appendChild(ripple);

    setTimeout(() => {
      ripple.remove();
    }, 600);
  }

  showFormLoading(form) {
    const submitBtn = form.querySelector('button[type="submit"]');
    if (submitBtn) {
      const originalText = submitBtn.textContent;
      submitBtn.disabled = true;
      submitBtn.innerHTML = '<span class="loading-spinner"></span> Enviando...';
      
      // Restaurar após um tempo (ou quando a resposta chegar)
      setTimeout(() => {
        submitBtn.disabled = false;
        submitBtn.textContent = originalText;
      }, 3000);
    }
  }

  // ========================================
  // MELHORIAS DE FORMULÁRIOS
  // ========================================
  setupFormEnhancements() {
    // Auto-resize para textareas
    document.querySelectorAll('textarea').forEach(textarea => {
      textarea.addEventListener('input', () => {
        textarea.style.height = 'auto';
        textarea.style.height = textarea.scrollHeight + 'px';
      });
    });

    // Validação em tempo real
    document.querySelectorAll('input, select, textarea').forEach(field => {
      field.addEventListener('blur', () => this.validateField(field));
      field.addEventListener('input', () => this.clearFieldError(field));
    });

    // Upload de arquivos com preview
    document.querySelectorAll('input[type="file"]').forEach(input => {
      input.addEventListener('change', (e) => this.handleFileUpload(e));
    });

    // Auto-save para formulários longos
    document.querySelectorAll('form').forEach(form => {
      if (form.dataset.autosave === 'true') {
        this.setupAutoSave(form);
      }
    });
  }

  validateField(field) {
    const value = field.value.trim();
    const required = field.hasAttribute('required');
    const pattern = field.getAttribute('pattern');
    const minLength = field.getAttribute('minlength');
    const maxLength = field.getAttribute('maxlength');

    // Limpar erros anteriores
    this.clearFieldError(field);

    // Validações
    if (required && !value) {
      this.showFieldError(field, 'Este campo é obrigatório');
      return false;
    }

    if (minLength && value.length < parseInt(minLength)) {
      this.showFieldError(field, `Mínimo de ${minLength} caracteres`);
      return false;
    }

    if (maxLength && value.length > parseInt(maxLength)) {
      this.showFieldError(field, `Máximo de ${maxLength} caracteres`);
      return false;
    }

    if (pattern && !new RegExp(pattern).test(value)) {
      this.showFieldError(field, 'Formato inválido');
      return false;
    }

    // Validações específicas por tipo
    if (field.type === 'email' && value && !this.isValidEmail(value)) {
      this.showFieldError(field, 'Email inválido');
      return false;
    }

    if (field.type === 'url' && value && !this.isValidUrl(value)) {
      this.showFieldError(field, 'URL inválida');
      return false;
    }

    // Mostrar sucesso
    this.showFieldSuccess(field);
    return true;
  }

  showFieldError(field, message) {
    field.classList.add('error');
    
    let errorElement = field.parentNode.querySelector('.form-error');
    if (!errorElement) {
      errorElement = document.createElement('div');
      errorElement.className = 'form-error';
      field.parentNode.appendChild(errorElement);
    }
    
    errorElement.textContent = message;
  }

  showFieldSuccess(field) {
    field.classList.remove('error');
    field.classList.add('success');
    
    const errorElement = field.parentNode.querySelector('.form-error');
    if (errorElement) {
      errorElement.remove();
    }
  }

  clearFieldError(field) {
    field.classList.remove('error', 'success');
    const errorElement = field.parentNode.querySelector('.form-error');
    if (errorElement) {
      errorElement.remove();
    }
  }

  isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  isValidUrl(url) {
    try {
      new URL(url);
      return true;
    } catch {
      return false;
    }
  }

  handleFileUpload(event) {
    const input = event.target;
    const files = Array.from(input.files);
    
    if (files.length === 0) return;

    // Criar preview para imagens
    files.forEach(file => {
      if (file.type.startsWith('image/')) {
        const reader = new FileReader();
        reader.onload = (e) => {
          this.createImagePreview(input, e.target.result, file.name);
        };
        reader.readAsDataURL(file);
      }
    });
  }

  createImagePreview(input, src, filename) {
    let previewContainer = input.parentNode.querySelector('.file-preview');
    if (!previewContainer) {
      previewContainer = document.createElement('div');
      previewContainer.className = 'file-preview';
      input.parentNode.appendChild(previewContainer);
    }

    const preview = document.createElement('div');
    preview.className = 'file-preview-item';
    preview.innerHTML = `
      <img src="${src}" alt="${filename}" style="max-width: 100px; max-height: 100px; border-radius: 8px;">
      <span>${filename}</span>
      <button type="button" class="remove-file">×</button>
    `;

    preview.querySelector('.remove-file').addEventListener('click', () => {
      preview.remove();
      input.value = '';
    });

    previewContainer.appendChild(preview);
  }

  setupAutoSave(form) {
    let timeout;
    const fields = form.querySelectorAll('input, select, textarea');
    
    fields.forEach(field => {
      field.addEventListener('input', () => {
        clearTimeout(timeout);
        timeout = setTimeout(() => {
          this.saveFormData(form);
        }, 1000);
      });
    });
  }

  saveFormData(form) {
    const formData = new FormData(form);
    const data = Object.fromEntries(formData.entries());
    
    localStorage.setItem(`form_${form.id || 'autosave'}`, JSON.stringify(data));
    
    // Mostrar indicador de salvamento
    this.showSaveIndicator(form, true);
    setTimeout(() => this.showSaveIndicator(form, false), 2000);
  }

  showSaveIndicator(form, show) {
    let indicator = form.querySelector('.save-indicator');
    if (!indicator) {
      indicator = document.createElement('div');
      indicator.className = 'save-indicator';
      indicator.style.cssText = `
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: var(--success-600);
        color: white;
        padding: 8px 16px;
        border-radius: 8px;
        font-size: 12px;
        opacity: 0;
        transition: opacity 0.3s;
        z-index: 1000;
      `;
      document.body.appendChild(indicator);
    }
    
    indicator.textContent = 'Salvando...';
    indicator.style.opacity = show ? '1' : '0';
  }

  // ========================================
  // MELHORIAS DE TABELAS
  // ========================================
  setupTableEnhancements() {
    // Ordenação de colunas
    document.querySelectorAll('.modern-table th.sortable').forEach(th => {
      th.addEventListener('click', () => this.sortTable(th));
    });

    // Busca em tabelas
    document.querySelectorAll('.table-search-input').forEach(input => {
      input.addEventListener('input', (e) => this.filterTable(e.target));
    });

    // Seleção de linhas
    document.querySelectorAll('.modern-table tbody tr').forEach(row => {
      row.addEventListener('click', (e) => {
        if (!e.target.matches('.table-action-btn')) {
          this.toggleRowSelection(row);
        }
      });
    });

    // Paginação
    document.querySelectorAll('.pagination-page, .pagination-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        this.handlePagination(e.target);
      });
    });
  }

  sortTable(header) {
    const table = header.closest('.modern-table');
    const tbody = table.querySelector('tbody');
    const rows = Array.from(tbody.querySelectorAll('tr'));
    const columnIndex = Array.from(header.parentNode.children).indexOf(header);
    const isAsc = header.classList.contains('asc');

    // Limpar classes de ordenação
    table.querySelectorAll('th').forEach(th => {
      th.classList.remove('asc', 'desc');
    });

    // Adicionar classe de ordenação
    header.classList.add(isAsc ? 'desc' : 'asc');

    // Ordenar linhas
    rows.sort((a, b) => {
      const aValue = a.children[columnIndex]?.textContent?.trim() || '';
      const bValue = b.children[columnIndex]?.textContent?.trim() || '';
      
      if (isAsc) {
        return bValue.localeCompare(aValue, 'pt-BR', { numeric: true });
      } else {
        return aValue.localeCompare(bValue, 'pt-BR', { numeric: true });
      }
    });

    // Reordenar linhas na tabela
    rows.forEach(row => tbody.appendChild(row));
  }

  filterTable(input) {
    const searchTerm = input.value.toLowerCase();
    const table = input.closest('.table-container').querySelector('.modern-table');
    const rows = table.querySelectorAll('tbody tr');

    rows.forEach(row => {
      const text = row.textContent.toLowerCase();
      const isVisible = text.includes(searchTerm);
      row.style.display = isVisible ? '' : 'none';
    });

    // Atualizar contador de resultados
    this.updateTableResults(table, searchTerm);
  }

  updateTableResults(table, searchTerm) {
    const visibleRows = table.querySelectorAll('tbody tr:not([style*="display: none"])');
    const totalRows = table.querySelectorAll('tbody tr').length;
    
    let resultInfo = table.parentNode.querySelector('.table-results-info');
    if (!resultInfo) {
      resultInfo = document.createElement('div');
      resultInfo.className = 'table-results-info';
      resultInfo.style.cssText = `
        font-size: 12px;
        color: var(--text-tertiary);
        margin-top: 8px;
      `;
      table.parentNode.appendChild(resultInfo);
    }

    if (searchTerm) {
      resultInfo.textContent = `Mostrando ${visibleRows.length} de ${totalRows} resultados`;
    } else {
      resultInfo.textContent = `${totalRows} resultados`;
    }
  }

  toggleRowSelection(row) {
    row.classList.toggle('selected');
    
    // Atualizar contador de seleção
    const table = row.closest('.modern-table');
    const selectedRows = table.querySelectorAll('tbody tr.selected');
    this.updateSelectionCount(table, selectedRows.length);
  }

  updateSelectionCount(table, count) {
    let selectionInfo = table.parentNode.querySelector('.table-selection-info');
    if (!selectionInfo) {
      selectionInfo = document.createElement('div');
      selectionInfo.className = 'table-selection-info';
      selectionInfo.style.cssText = `
        font-size: 12px;
        color: var(--primary-600);
        margin-top: 8px;
      `;
      table.parentNode.appendChild(selectionInfo);
    }

    if (count > 0) {
      selectionInfo.textContent = `${count} item(s) selecionado(s)`;
      selectionInfo.style.display = 'block';
    } else {
      selectionInfo.style.display = 'none';
    }
  }

  handlePagination(button) {
    const currentPage = parseInt(button.dataset.page) || 1;
    const table = button.closest('.table-container').querySelector('.modern-table');
    
    // Simular mudança de página (em uma implementação real, faria uma requisição AJAX)
    this.loadTablePage(table, currentPage);
  }

  loadTablePage(table, page) {
    // Simular carregamento
    const tbody = table.querySelector('tbody');
    tbody.style.opacity = '0.5';
    
    setTimeout(() => {
      tbody.style.opacity = '1';
      // Aqui você faria a requisição AJAX para carregar os dados da página
      console.log(`Carregando página ${page}`);
    }, 300);
  }

  // ========================================
  // NOTIFICAÇÕES E FEEDBACK
  // ========================================
  setupNotifications() {
    // Interceptar notificações do sistema
    if (window.showPopup) {
      const originalShowPopup = window.showPopup;
      window.showPopup = (type, title, message, timeout) => {
        this.showModernNotification(type, title, message, timeout);
        originalShowPopup(type, title, message, timeout);
      };
    }
  }

  showModernNotification(type, title, message, timeout = 5000) {
    const notification = document.createElement('div');
    notification.className = `modern-notification ${type}`;
    notification.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      background: var(--bg-elevated);
      border: 1px solid var(--border-primary);
      border-left: 4px solid var(--${type === 'success' ? 'success' : type === 'error' ? 'error' : 'warning'}-500);
      border-radius: 8px;
      padding: 16px;
      box-shadow: var(--shadow-lg);
      max-width: 400px;
      z-index: 10000;
      transform: translateX(100%);
      transition: transform 0.3s ease-out;
    `;

    notification.innerHTML = `
      <div style="display: flex; align-items: flex-start; gap: 12px;">
        <div class="notification-icon" style="
          width: 24px;
          height: 24px;
          border-radius: 50%;
          background: var(--${type === 'success' ? 'success' : type === 'error' ? 'error' : 'warning'}-100);
          color: var(--${type === 'success' ? 'success' : type === 'error' ? 'error' : 'warning'}-600);
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 14px;
          flex-shrink: 0;
        ">
          ${type === 'success' ? '✓' : type === 'error' ? '✕' : '⚠'}
        </div>
        <div style="flex: 1;">
          <div style="font-weight: 600; margin-bottom: 4px; color: var(--text-primary);">${title}</div>
          <div style="font-size: 14px; color: var(--text-secondary);">${message}</div>
        </div>
        <button class="notification-close" style="
          background: none;
          border: none;
          color: var(--text-tertiary);
          cursor: pointer;
          padding: 4px;
          border-radius: 4px;
          font-size: 16px;
        ">×</button>
      </div>
    `;

    document.body.appendChild(notification);

    // Animar entrada
    setTimeout(() => {
      notification.style.transform = 'translateX(0)';
    }, 100);

    // Configurar fechamento
    const closeBtn = notification.querySelector('.notification-close');
    closeBtn.addEventListener('click', () => this.closeNotification(notification));

    // Auto-close
    if (timeout > 0) {
      setTimeout(() => this.closeNotification(notification), timeout);
    }
  }

  closeNotification(notification) {
    notification.style.transform = 'translateX(100%)';
    setTimeout(() => {
      if (notification.parentNode) {
        notification.parentNode.removeChild(notification);
      }
    }, 300);
  }

  // ========================================
  // ATALHOS DE TECLADO
  // ========================================
  setupKeyboardShortcuts() {
    document.addEventListener('keydown', (e) => {
      // Ctrl/Cmd + K para busca
      if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        this.focusSearch();
      }

      // Ctrl/Cmd + N para novo item
      if ((e.ctrlKey || e.metaKey) && e.key === 'n') {
        e.preventDefault();
        this.createNewItem();
      }

      // Escape para fechar modais/overlays
      if (e.key === 'Escape') {
        this.closeModals();
      }

      // Enter para submeter formulários
      if (e.key === 'Enter' && e.target.matches('input, select, textarea')) {
        const form = e.target.closest('form');
        if (form && !e.target.matches('textarea')) {
          e.preventDefault();
          form.requestSubmit();
        }
      }
    });
  }

  focusSearch() {
    const searchInput = document.querySelector('.table-search-input, input[type="search"]');
    if (searchInput) {
      searchInput.focus();
      searchInput.select();
    }
  }

  createNewItem() {
    const newButton = document.querySelector('a[href*="Create"], .btn-primary');
    if (newButton) {
      newButton.click();
    }
  }

  closeModals() {
    // Fechar modais do Bootstrap
    const modals = document.querySelectorAll('.modal.show');
    modals.forEach(modal => {
      const closeBtn = modal.querySelector('[data-bs-dismiss="modal"]');
      if (closeBtn) {
        closeBtn.click();
      }
    });

    // Fechar overlays customizados
    const overlays = document.querySelectorAll('.sidebar-overlay.active');
    overlays.forEach(overlay => {
      overlay.classList.remove('active');
    });
  }
}

// Inicializar quando o DOM estiver pronto
document.addEventListener('DOMContentLoaded', () => {
  window.modernUI = new ModernUI();
});

// Adicionar estilos CSS para animações
const style = document.createElement('style');
style.textContent = `
  @keyframes ripple {
    to {
      transform: scale(4);
      opacity: 0;
    }
  }

  .loading-spinner {
    width: 16px;
    height: 16px;
    border: 2px solid transparent;
    border-top: 2px solid currentColor;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    display: inline-block;
    margin-right: 8px;
  }

  .file-preview {
    display: flex;
    gap: 8px;
    margin-top: 8px;
    flex-wrap: wrap;
  }

  .file-preview-item {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px;
    background: var(--bg-secondary);
    border-radius: 8px;
    font-size: 12px;
  }

  .remove-file {
    background: var(--error-100);
    color: var(--error-600);
    border: none;
    border-radius: 50%;
    width: 20px;
    height: 20px;
    cursor: pointer;
    font-size: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .modern-table tbody tr.selected {
    background: var(--primary-50) !important;
    border-left: 4px solid var(--primary-500);
  }

  .modern-table tbody tr.selected:hover {
    background: var(--primary-100) !important;
  }
`;
document.head.appendChild(style);
