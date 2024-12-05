const togglePassword = document.querySelector("#eye-icon")
const togglePasswordTwo = document.querySelector("#eye-icon-2") // Para confirmação da senha da página de registro
const password = document.querySelector("#password")
const confirmPassword = document.querySelector("#confirm-password") // Para confirmação da senha da página de registro
function alterarVisibilidadeDoCampoSenha(icon, input) {
    icon.addEventListener("click", function () {
        const type = input.type === "password" ? "text" : "password"
        input.type = type
        this.classList.toggle("fa-eye")
        this.classList.toggle("fa-eye-slash")
    })
}

alterarVisibilidadeDoCampoSenha(togglePassword, password)
if (togglePasswordTwo) {
    alterarVisibilidadeDoCampoSenha(togglePasswordTwo, confirmPassword)
}

const inputCpf = document.querySelector("#cpf-input") // Para máscara do cpf

inputCpf.addEventListener('keypress', () => {
    let inputLength = inputCpf.value.length
    if (inputLength === 3 || inputLength === 7) {
        inputCpf.value += '.'
    } else if (inputLength === 11) {
        inputCpf.value += '-'
    }
})