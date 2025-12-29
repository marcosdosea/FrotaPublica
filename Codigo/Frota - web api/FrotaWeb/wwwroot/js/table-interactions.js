/**
 * Interações de Tabela - Clique na linha para ver detalhes
 */

(function() {
    'use strict';

    function initTableInteractions() {
        const tables = document.querySelectorAll('.table-modern, .table');
        
        tables.forEach(table => {
            const rows = table.querySelectorAll('tbody tr');
            
            rows.forEach(row => {
                // Ignora se a linha tiver botões de ação
                const actionButtons = row.querySelectorAll('.table-action-btn, .btn, a[href*="Edit"], a[href*="Delete"], a[href*="Details"]');
                
                if (actionButtons.length > 0) {
                    // Previne clique na linha se clicar nos botões
                    actionButtons.forEach(button => {
                        button.addEventListener('click', function(e) {
                            e.stopPropagation();
                        });
                    });
                }
                
                // Adiciona evento de clique na linha
                row.addEventListener('click', function(e) {
                    // Não faz nada se clicar em botões ou links
                    if (e.target.closest('a, button, .table-action-btn')) {
                        return;
                    }
                    
                    // Usa data attribute ou procura link de detalhes
                    const detailsUrl = row.getAttribute('data-details-url');
                    if (detailsUrl) {
                        window.location.href = detailsUrl;
                    } else {
                        const detailsLink = row.querySelector('a[href*="Details"], a.details');
                        if (detailsLink) {
                            window.location.href = detailsLink.href;
                        }
                    }
                });
                
                // Adiciona estilo hover
                row.style.cursor = 'pointer';
            });
        });
    }

    // Inicializar quando DOM estiver pronto
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initTableInteractions);
    } else {
        initTableInteractions();
    }

    // Reaplicar para tabelas dinâmicas
    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            mutation.addedNodes.forEach(function(node) {
                if (node.nodeType === 1 && (node.classList?.contains('table-modern') || node.querySelector('.table-modern'))) {
                    initTableInteractions();
                }
            });
        });
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true
    });

})();

