/**
 * Paginação Client-Side
 * Divide os resultados em páginas de 20 itens
 */
(function() {
    'use strict';

    function initPagination() {
        const tables = document.querySelectorAll('.table-modern');
        
        tables.forEach(table => {
            const tbody = table.querySelector('tbody');
            if (!tbody) return;
            
            const rows = Array.from(tbody.querySelectorAll('tr'));
            const totalItems = rows.length;
            const itemsPerPage = 20;
            const totalPages = Math.ceil(totalItems / itemsPerPage);
            
            // Se tiver menos de 20 itens, não precisa de paginação
            if (totalItems <= itemsPerPage) {
                return;
            }
            
            // Criar container de paginação
            const paginationContainer = document.createElement('nav');
            paginationContainer.className = 'pagination-container';
            paginationContainer.style.marginTop = 'var(--space-6)';
            paginationContainer.style.display = 'flex';
            paginationContainer.style.justifyContent = 'center';
            
            const pagination = document.createElement('div');
            pagination.className = 'pagination';
            
            let currentPage = 0;
            
            function renderPagination() {
                pagination.innerHTML = '';
                
                // Botão anterior
                if (currentPage > 0) {
                    const prevBtn = document.createElement('a');
                    prevBtn.className = 'pagination-btn';
                    prevBtn.href = '#';
                    prevBtn.innerHTML = '<i class="fas fa-chevron-left"></i>';
                    prevBtn.addEventListener('click', (e) => {
                        e.preventDefault();
                        currentPage--;
                        showPage(currentPage);
                        renderPagination();
                    });
                    pagination.appendChild(prevBtn);
                }
                
                // Números das páginas
                const startPage = Math.max(0, currentPage - 2);
                const endPage = Math.min(totalPages - 1, currentPage + 2);
                
                for (let i = startPage; i <= endPage; i++) {
                    const pageBtn = document.createElement('a');
                    pageBtn.className = `pagination-btn ${i === currentPage ? 'active' : ''}`;
                    pageBtn.href = '#';
                    pageBtn.textContent = i + 1;
                    pageBtn.addEventListener('click', (e) => {
                        e.preventDefault();
                        currentPage = i;
                        showPage(currentPage);
                        renderPagination();
                    });
                    pagination.appendChild(pageBtn);
                }
                
                // Botão próximo
                if (currentPage < totalPages - 1) {
                    const nextBtn = document.createElement('a');
                    nextBtn.className = 'pagination-btn';
                    nextBtn.href = '#';
                    nextBtn.innerHTML = '<i class="fas fa-chevron-right"></i>';
                    nextBtn.addEventListener('click', (e) => {
                        e.preventDefault();
                        currentPage++;
                        showPage(currentPage);
                        renderPagination();
                    });
                    pagination.appendChild(nextBtn);
                }
            }
            
            function showPage(page) {
                const start = page * itemsPerPage;
                const end = start + itemsPerPage;
                
                rows.forEach((row, index) => {
                    if (index >= start && index < end) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            }
            
            // Inicializar
            paginationContainer.appendChild(pagination);
            table.parentElement.parentElement.parentElement.appendChild(paginationContainer);
            showPage(0);
            renderPagination();
        });
    }
    
    // Inicializar quando DOM estiver pronto
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPagination);
    } else {
        initPagination();
    }
})();

