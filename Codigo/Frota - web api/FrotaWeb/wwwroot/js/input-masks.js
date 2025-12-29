/**
 * Máscaras de Input - Componentizado
 */

(function() {
    'use strict';

    // Máscara CPF
    function applyCpfMask(input) {
        input.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            value = value.replace(/(\d{3})(\d)/, '$1.$2');
            value = value.replace(/(\d{3})(\d)/, '$1.$2');
            value = value.replace(/(\d{3})(\d{1,2})$/, '$1-$2');
            e.target.value = value;
        });
    }

    // Máscara Placa
    function applyPlacaMask(input) {
        input.addEventListener('input', function(e) {
            let value = e.target.value.replace(/[^A-Z0-9]/gi, '').toUpperCase();
            if (value.length <= 3) {
                e.target.value = value;
            } else {
                value = value.substring(0, 3) + '-' + value.substring(3, 7);
                e.target.value = value;
            }
        });
    }

    // Máscara Telefone
    function applyTelefoneMask(input) {
        input.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length <= 10) {
                value = value.replace(/(\d{2})(\d)/, '($1) $2');
                value = value.replace(/(\d{4})(\d)/, '$1-$2');
            } else {
                value = value.replace(/(\d{2})(\d)/, '($1) $2');
                value = value.replace(/(\d{5})(\d)/, '$1-$2');
            }
            e.target.value = value;
        });
    }

    // Máscara CEP
    function applyCepMask(input) {
        input.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            value = value.replace(/(\d{5})(\d)/, '$1-$2');
            e.target.value = value;
        });
    }

    // Máscara Data
    function applyDataMask(input) {
        input.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            value = value.replace(/(\d{2})(\d)/, '$1/$2');
            value = value.replace(/(\d{2})\/(\d{2})(\d)/, '$1/$2/$3');
            e.target.value = value;
        });
    }

    // Máscara Hora
    function applyHoraMask(input) {
        input.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            value = value.replace(/(\d{2})(\d)/, '$1:$2');
            e.target.value = value;
        });
    }

    // Máscara Valor/Moeda
    function applyValorMask(input) {
        input.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            value = (value / 100).toFixed(2) + '';
            value = value.replace('.', ',');
            value = value.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
            e.target.value = 'R$ ' + value;
        });
    }

    // Aplicar máscaras automaticamente
    function initMasks() {
        // CPF
        document.querySelectorAll('.input-cpf, input[data-mask="cpf"]').forEach(applyCpfMask);
        
        // Placa
        document.querySelectorAll('.input-placa, input[data-mask="placa"]').forEach(applyPlacaMask);
        
        // Telefone
        document.querySelectorAll('.input-telefone, input[data-mask="telefone"]').forEach(applyTelefoneMask);
        
        // CEP
        document.querySelectorAll('.input-cep, input[data-mask="cep"]').forEach(applyCepMask);
        
        // Data
        document.querySelectorAll('.input-data, input[data-mask="data"]').forEach(applyDataMask);
        
        // Hora
        document.querySelectorAll('.input-hora, input[data-mask="hora"]').forEach(applyHoraMask);
        
        // Valor
        document.querySelectorAll('.input-valor, input[data-mask="valor"]').forEach(applyValorMask);
    }

    // Inicializar quando DOM estiver pronto
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initMasks);
    } else {
        initMasks();
    }

    // Reaplicar máscaras para elementos dinâmicos
    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            mutation.addedNodes.forEach(function(node) {
                if (node.nodeType === 1) { // Element node
                    if (node.classList && node.classList.contains('input-cpf')) {
                        applyCpfMask(node);
                    }
                    if (node.classList && node.classList.contains('input-placa')) {
                        applyPlacaMask(node);
                    }
                    // Adicionar outros conforme necessário
                }
            });
        });
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true
    });

})();

