const togglePassword = document.querySelector("#eye-icon");
const togglePasswordTwo = document.querySelector("#eye-icon-2"); // Para confirmação da senha da página de registro
const password = document.querySelector("#password");
const confirmPassword = document.querySelector("#confirm-password"); // Para confirmação da senha da página de registro
function alterarVisibilidadeDoCampoSenha(icon, input) {
    icon.addEventListener("click", function () {
        const type = input.type === "password" ? "text" : "password";
        input.type = type;
        this.classList.toggle("fa-eye");
        this.classList.toggle("fa-eye-slash");
    });
}
alterarVisibilidadeDoCampoSenha(togglePassword, password);
alterarVisibilidadeDoCampoSenha(togglePasswordTwo, confirmPassword);