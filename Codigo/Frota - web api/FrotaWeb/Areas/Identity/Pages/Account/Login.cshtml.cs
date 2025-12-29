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
using Core.DTO;
using Microsoft.AspNetCore.Authentication.Cookies;
using System.Security.Claims;
using Microsoft.AspNetCore.Components;

namespace FrotaWeb.Areas.Identity.Pages.Account;

public class LoginModel : PageModel
{
    private readonly SignInManager<UsuarioIdentity> _signInManager;
    private readonly UserManager<UsuarioIdentity> _userManager;
    private readonly ILogger<LoginModel> _logger;
    private readonly IFrotaService _frotaService;

    public LoginModel(SignInManager<UsuarioIdentity> signInManager, UserManager<UsuarioIdentity> userManager, ILogger<LoginModel> logger, IFrotaService frotaService)
    {
        _signInManager = signInManager;
        _userManager = userManager;
        _logger = logger;
        _frotaService = frotaService;
    }

    [BindProperty]
    public InputModel Input { get; set; }

    public IList<AuthenticationScheme> ExternalLogins { get; set; }

    public string ReturnUrl { get; set; }

    [TempData]
    public string ErrorMessage { get; set; }

    public class InputModel
    {
        [CPF(ErrorMessage = "O cpf informado não é válido")]
        [Required(ErrorMessage = "O cpf é obrigatório")]
        [StringLength(14, MinimumLength = 14, ErrorMessage = "O cpf deve ter 11 caracteres")]
        public string UserName { get; set; }

        [Required(ErrorMessage = "A senha é obrigatória")]
        [StringLength(20, ErrorMessage = "A senha deve ter entre 8 e 20 caracteres", MinimumLength = 8)]
        [DataType(DataType.Password)]
        public string Password { get; set; }

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

        await HttpContext.SignOutAsync(IdentityConstants.ExternalScheme);

        ExternalLogins = (await _signInManager.GetExternalAuthenticationSchemesAsync()).ToList();

        ReturnUrl = returnUrl;
    }

    public async Task<IActionResult> OnPostAsync(string returnUrl = null)
    {
        returnUrl ??= Url.Content("~/");
        ExternalLogins = (await _signInManager.GetExternalAuthenticationSchemesAsync()).ToList();

        if (!ModelState.IsValid)
            return Page();

        var userName = NormalizarUserName(Input.UserName);
        var user = _userManager.Users.SingleOrDefault(u => u.UserName == userName);

        if (user == null)
        {
            ModelState.AddModelError(string.Empty, "Login inválido");
            return Page();
        }

        var result = await _signInManager.PasswordSignInAsync(user, Input.Password, Input.RememberMe, lockoutOnFailure: false);

        return await ProcessarResultadoLogin(result, user, userName, returnUrl);
    }

    private async Task<IActionResult> ProcessarResultadoLogin(
        Microsoft.AspNetCore.Identity.SignInResult result, 
        UsuarioIdentity user, 
        string userName, 
        string returnUrl)
    {
        if (result.Succeeded)
            return await ProcessarLoginSucesso(user, userName, returnUrl);

        if (result.RequiresTwoFactor)
            return RedirectToPage("./LoginWith2fa", new { ReturnUrl = returnUrl, RememberMe = Input.RememberMe });

        if (result.IsLockedOut)
        {
            _logger.LogWarning("User account locked out.");
            return RedirectToPage("./Lockout");
        }

        ModelState.AddModelError(string.Empty, "Login inválido");
        return Page();
    }

    private async Task<IActionResult> ProcessarLoginSucesso(UsuarioIdentity user, string userName, string returnUrl)
    {
        var isAdmin = await _userManager.IsInRoleAsync(user, "Admin");

        if (isAdmin)
        {
            _logger.LogInformation("Admin user has been logged in: {UserName}", userName);
        }
        else
        {
            await ConfigurarDadosFrotaEUnidade(user, userName);
        }

        _logger.LogInformation("User logged in: {UserName}", userName);
        return LocalRedirect(returnUrl);
    }

    private async Task ConfigurarDadosFrotaEUnidade(UsuarioIdentity user, string userName)
    {
        var pessoaInfo = await _frotaService.GetFrotaEUnidadeByUsernameAsync(userName);

        PersistirDadosNaSessao(pessoaInfo);
        await AtualizarClaimsSeNecessario(user, pessoaInfo);
    }

    private void PersistirDadosNaSessao(PessoaInfoDto pessoaInfo)
    {
        HttpContext.Session.SetInt32("FrotaId", (int)pessoaInfo.IdFrota);
        HttpContext.Session.SetInt32("UnidadeId", (int)pessoaInfo.IdUnidade);
    }

    private async Task AtualizarClaimsSeNecessario(UsuarioIdentity user, PessoaInfoDto pessoaInfo)
    {
        var userClaims = await _userManager.GetClaimsAsync(user);
        
        bool frotaAtualizada = await AtualizarClaimFrota(user, userClaims, pessoaInfo.IdFrota);
        bool unidadeAtualizada = await AtualizarClaimUnidade(user, userClaims, pessoaInfo.IdUnidade);

        if (frotaAtualizada || unidadeAtualizada)
        {
            await ReautenticarUsuario(user);
        }
    }

    private async Task<bool> AtualizarClaimFrota(UsuarioIdentity user, IList<Claim> userClaims, uint idFrota)
    {
        var claimFrota = userClaims.FirstOrDefault(c => c.Type == "FrotaId");
        var valorFrota = idFrota.ToString();

        if (claimFrota?.Value == valorFrota)
            return false;

        if (claimFrota != null)
            await _userManager.RemoveClaimAsync(user, claimFrota);

        await _userManager.AddClaimAsync(user, new Claim("FrotaId", valorFrota));
        return true;
    }

    private async Task<bool> AtualizarClaimUnidade(UsuarioIdentity user, IList<Claim> userClaims, uint idUnidade)
    {
        var claimUnidade = userClaims.FirstOrDefault(c => c.Type == "UnidadeId");
        var valorUnidade = idUnidade.ToString();

        if (claimUnidade?.Value == valorUnidade)
            return false;

        if (claimUnidade != null)
            await _userManager.RemoveClaimAsync(user, claimUnidade);

        await _userManager.AddClaimAsync(user, new Claim("UnidadeId", valorUnidade));
        return true;
    }

    private async Task ReautenticarUsuario(UsuarioIdentity user)
    {
        await _signInManager.SignInAsync(user, isPersistent: Input.RememberMe);
    }

    private string NormalizarUserName(string userName)
    {
        return userName.Replace(".", "").Replace("-", "");
    }
}