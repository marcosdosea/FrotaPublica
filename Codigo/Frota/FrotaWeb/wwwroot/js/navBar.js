const sidebar = document.querySelector(".sidebar");
const nav = document.querySelector(".sidebar nav");
const buttons = document.querySelectorAll('.menu > button');
const submenus = document.querySelectorAll('.submenu');

const toggleOpen = () => {
    const isOpen = sidebar.classList.toggle("open");
    if (!isOpen) {
        closeAllSubmenus();
    }
};

// Listas de controllers para cada submenu
const veiculosControllers = ["Veiculo", "Abastecimento", "MarcaVeiculo", "ModeloVeiculo"];
const manutencaoControllers = ["Solicitacaomanutencao", "Manutencao", "ManutencaoPecaInsumo"];
const pecasInsumosControllers = ["PecaInsumo", "MarcaPecaInsumo"];

// Obtém o caminho da URL (ex: "/Veiculo")
const currentPath = window.location.pathname;

// Extrai o nome da controller (ex: "Veiculo")
const controllerName = currentPath.split('/')[1]; // Pega o primeiro segmento após o domínio

// Função para ajustar o menu ao redimensionar a tela
function resize() {
    if (window.innerWidth >= 768) {
        sidebar.classList.add("open");
    } else {
        sidebar.classList.remove("open");
        closeAllSubmenus();
    }
}

window.addEventListener("resize", resize);

resize();

// Função para ativar o botão com base na controller
function activateButton() {
    let activeButton = null;

    // Verifica em qual grupo a controller pertence
    if (!controllerName) {
        buttons[0].classList.add("active");
    } else if (veiculosControllers.includes(controllerName)) {
        activeButton = document.querySelector(`[onclick="toggleSubmenu('veiculos-submenu')"]`);
    } else if (manutencaoControllers.includes(controllerName)) {
        activeButton = document.querySelector(`[onclick="toggleSubmenu('manutencao-submenu')"]`);
    } else if (pecasInsumosControllers.includes(controllerName)) {
        activeButton = document.querySelector(`[onclick="toggleSubmenu('pecasInsumos-submenu')"]`);
    } else {
        // Caso a controller não pertença a nenhum submenu, procura um botão direto correspondente
        activeButton = document.getElementById(controllerName);
    }

    if (activeButton) {
        // Remove a classe "active" de todos os botões
        buttons.forEach((button) => button.classList.remove("active"));

        // Marca o botão correspondente como "ativo"
        activeButton.classList.add("active");

        // Ajusta a barra de destaque para o botão correto
        const activeIndex = Array.from(buttons).indexOf(activeButton); // Localiza o índice do botão ativo
        nav.style.setProperty("--top", `${activeIndex === 0 ? 0 : activeIndex * 50}px`);
    }
}

// Chama a função para ativar o botão correto ao carregar
activateButton();

buttons.forEach((button, index) => {
    button.addEventListener("click", () => {
        // Fecha os submenus ao clicar em um botão principal que não expande submenus
        const isExpander = button.hasAttribute("onclick") && button.getAttribute("onclick").includes("toggleSubmenu");
        if (!isExpander) {
            closeAllSubmenus();
        }

        // Remove a classe "active" de todos os botões
        buttons.forEach((b) => b.classList.remove("active"));

        // Adiciona a classe "active" ao botão clicado
        button.classList.add("active");

        // Ajusta a propriedade CSS para indicar a posição
        nav.style.setProperty("--top", `${index === 0 ? 0 : index * 50}px`);
    });
});

function closeAllSubmenus() {
    // Fecha todos os submenus
    submenus.forEach((submenu) => {
        submenu.classList.remove("open");
        submenu.style.maxHeight = null; // Reseta a altura para animação (opcional)
    });
}

function toggleSubmenu(id) {
    // Verifica se a sidebar está retraída
    const isSidebarClosed = !sidebar.classList.contains("open");
    const submenu = document.getElementById(id);
    const isSubmenuOpen = submenu.classList.contains("open");

    if (isSidebarClosed) {
        // Expande a sidebar antes de abrir o submenu
        sidebar.classList.add("open");
    }

    // Se o submenu já está aberto, apenas feche ele
    if (isSubmenuOpen) {
        submenu.classList.remove("open");
        submenu.style.maxHeight = null;
        return;
    }

    // Fecha todos os submenus antes de abrir o submenu clicado
    closeAllSubmenus();

    // Abre o submenu clicado
    submenu.classList.add("open");
    submenu.style.maxHeight = submenu.scrollHeight + "px";
}

// Adiciona evento de toggle apenas em telas pequenas
if (window.innerWidth < 768) {
    buttons[0].addEventListener("click", () => {
        toggleOpen();
    });
}
