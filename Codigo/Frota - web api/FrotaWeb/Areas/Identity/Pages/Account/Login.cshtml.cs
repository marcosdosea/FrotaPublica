// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
#nullable disable

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Core;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;
using Util;
using Core.Service;
using Microsoft.AspNetCore.Authentication.Cookies;
using System.Security.Claims;
using Microsoft.AspNetCore.Components;

namespace FrotaWeb.Areas.Identity.Pages.Account;

public class LoginModel : PageModel
{
    private readonly SignInManager<UsuarioIdentity> _signInManager;
    private readonly UserManager<UsuarioIdentity> userManager;
    private readonly ILogger<LoginModel> _logger;
    private readonly IFrotaService frotaService;
    private UserManager<UsuarioIdentity> UserManager { get; set; }


    public LoginModel(SignInManager<UsuarioIdentity> signInManager, UserManager<UsuarioIdentity> userManager, ILogger<LoginModel> logger, IFrotaService frotaService)
    {
        _signInManager = signInManager;
        this.userManager = userManager;
        _logger = logger;
        this.frotaService = frotaService;
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
    public IList<AuthenticationScheme> ExternalLogins { get; set; }

    /// <summary>
    ///     This API supports the ASP.NET Core Identity default UI infrastructure and is not intended to be used
    ///     directly from your code. This API may change or be removed in future releases.
    /// </summary>
    public string ReturnUrl { get; set; }

    /// <summary>
    ///     This API supports the ASP.NET Core Identity default UI infrastructure and is not intended to be used
    ///     directly from your code. This API may change or be removed in future releases.
    /// </summary>
    [TempData]
    public string ErrorMessage { get; set; }

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
        [CPF(ErrorMessage = "O cpf informado n�o � v�lido")]
        [Required(ErrorMessage = "O cpf � obrigat�rio")]
        [StringLength(14, MinimumLength = 14, ErrorMessage = "O cpf deve ter 11 caracteres")]
        public string UserName { get; set; }

        /// <summary>
        ///     This API supports the ASP.NET Core Identity default UI infrastructure and is not intended to be used
        ///     directly from your code. This API may change or be removed in future releases.
        /// </summary>
        [Required(ErrorMessage = "A senha � obrigat�ria")]
        [StringLength(20, ErrorMessage = "A senha deve ter entre 8 e 20 caracteres", MinimumLength = 8)]
        [DataType(DataType.Password)]
        public string Password { get; set; }

        /// <summary>
        ///     This API supports the ASP.NET Core Identity default UI infrastructure and is not intended to be used
        ///     directly from your code. This API may change or be removed in future releases.
        /// </summary>
        [Display(Name = "Lembrar de mim?")]
        public bool RememberMe { get; set; }
    }

    public async Task OnGetAsync(string returnUrl = null)
    {
        if (!string.IsNullOrEmpty(ErrorMessage))
        {
            ModelState.AddModelError(string.Empty, ErrorMessage);
        }

        returnUrl ??= Url.Content("~/");

        // Clear the existing external cookie to ensure a clean login process
        await HttpContext.SignOutAsync(IdentityConstants.ExternalScheme);

        ExternalLogins = (await _signInManager.GetExternalAuthenticationSchemesAsync()).ToList();

        ReturnUrl = returnUrl;
    }

    public async Task<IActionResult> OnPostAsync(string returnUrl = null)
    {
        returnUrl ??= Url.Content("~/");

        ExternalLogins = (await _signInManager.GetExternalAuthenticationSchemesAsync()).ToList();

        if (ModelState.IsValid)
        {
            // This doesn't count login failures towards account lockout
            // To enable password failures to trigger account lockout, set lockoutOnFailure: true
            var userName = Input.UserName.Replace(".", "").Replace("-", "");
            var user = userManager.Users.SingleOrDefault(u => u.UserName == userName);
            if (user != null)
            {
                var result = await _signInManager.PasswordSignInAsync(user, Input.Password, Input.RememberMe, lockoutOnFailure: false);
                if (result.Succeeded)
                {
                    // Persistir o id da frota na sess�o
                    int idFrotaDoUsuario = (int)frotaService.GetFrotaByUsername(user.UserName);
                    HttpContext.Session.SetInt32("FrotaId", idFrotaDoUsuario);

                    // Persistir o id da unidade na sess�o
                    int idUnidadeDoUsuario = (int)frotaService.GetUnidadeByUsername(user.UserName);
                    HttpContext.Session.SetInt32("UnidadeId", idUnidadeDoUsuario);

                    // Atualizar ou adicionar a claim personalizada de Frota no banco de dados
                    var existingClaimFrota = (await userManager.GetClaimsAsync(user)).FirstOrDefault(c => c.Type == "FrotaId");
                    if (existingClaimFrota != null)
                    {
                        await userManager.RemoveClaimAsync(user, existingClaimFrota);
                    }
                    await userManager.AddClaimAsync(user, new Claim("FrotaId", idFrotaDoUsuario.ToString()));

                    // Atualizar ou adicionar a claim personalizada de Unidade no banco de dados
                    var existingClaimUnidade = (await userManager.GetClaimsAsync(user)).FirstOrDefault(c => c.Type == "UnidadeId");
                    if (existingClaimUnidade != null)
                    {
                        await userManager.RemoveClaimAsync(user, existingClaimUnidade);
                    }
                    await userManager.AddClaimAsync(user, new Claim("UnidadeId", idUnidadeDoUsuario.ToString()));

                    // Reautenticar o usu�rio para carregar as novas claims
                    await _signInManager.SignInAsync(user, isPersistent: true);
                    _logger.LogInformation("User logged in.");
                    return LocalRedirect(returnUrl);
                }
                if (result.RequiresTwoFactor)
                {
                    return RedirectToPage("./LoginWith2fa", new { ReturnUrl = returnUrl, RememberMe = Input.RememberMe });
                }
                if (result.IsLockedOut)
                {
                    _logger.LogWarning("User account locked out.");
                    return RedirectToPage("./Lockout");
                }
                else
                {
                    ModelState.AddModelError(string.Empty, "Login inv�lido");
                    return Page();
                }
            }
        }
        // If we got this far, something failed, redisplay form
        return Page();
    }
}
