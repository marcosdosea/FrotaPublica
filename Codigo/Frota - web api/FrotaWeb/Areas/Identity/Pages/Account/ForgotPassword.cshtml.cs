using System.ComponentModel.DataAnnotations;
using System.Text;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.WebUtilities;
using Service;

namespace FrotaWeb.Areas.Identity.Pages.Account
{
    public class ForgotPasswordModel : PageModel
    {
        private readonly UserManager<UsuarioIdentity> _userManager;
        private readonly IEmailSender _emailSender;
        private readonly IPessoaService _pessoaService;

        public ForgotPasswordModel(UserManager<UsuarioIdentity> userManager, IPessoaService pessoaService, IEmailSender emailSender)
        {
            _userManager = userManager;
            _emailSender = emailSender;
            _pessoaService = pessoaService;
        }

        /// <summary>
        ///     This API supports the ASP.NET Core Identity default UI infrastructure and is not intended to be used
        ///     directly from your code. This API may change or be removed in future releases.
        /// </summary>
        [BindProperty]
        public InputModel Input { get; set; }

        /// <summary>
        ///     This API supports the ASP.NET Core Identity default UI infrastructure and is not intended to be used
        ///     directly from your code. This API may change or be removed in future releases.
        /// </summary>
        public class InputModel
        {
            /// <summary>
            ///     This API supports the ASP.NET Core Identity default UI infrastructure and is not intended to be used
            ///     directly from your code. This API may change or be removed in future releases.
            /// </summary>
            [Required]
            [EmailAddress]
            public string Email { get; set; }
        }

        public async Task<IActionResult> OnPostAsync()
        {
            if (ModelState.IsValid)
            {
                try
                {
                    var user = await _userManager.FindByEmailAsync(Input.Email);

                    // Verificar se o usuário existe
                    if (user == null)
                    {
                        ModelState.AddModelError("Input.Email", "Este email não está cadastrado no sistema.");
                        return Page();
                    }

                    // Verificar se o email está confirmado
                    if (!(await _userManager.IsEmailConfirmedAsync(user)))
                    {
                        ModelState.AddModelError("Input.Email", "Este email ainda não foi confirmado. Verifique sua caixa de entrada.");
                        return Page();
                    }

                    // Gerar token de redefinição de senha
                    var resetToken = await _userManager.GeneratePasswordResetTokenAsync(user);
                    resetToken = WebEncoders.Base64UrlEncode(Encoding.UTF8.GetBytes(resetToken));

                    // Construir URL de callback
                    var callbackUrl = Url.Page(
                        "/Account/ResetPassword",
                        pageHandler: null,
                        values: new { area = "Identity", code = resetToken },
                        protocol: Request.Scheme);

                    // Obter informações do usuário para o envio de email
                    var pessoa = _pessoaService.GetUserByEmailAsync(Input.Email);
                    string nomeUsuario = pessoa?.Nome ?? "Usuário";

                    // Enviar email
                    await _emailSender.SendEmailAsync(
                        Input.Email,
                        nomeUsuario,
                        callbackUrl
                    );

                    return RedirectToPage("./ForgotPasswordConfirmation");
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "Ocorreu um erro ao processar sua solicitação. Por favor, tente novamente.");
                }
            }

            return Page();
        }
    }
}
