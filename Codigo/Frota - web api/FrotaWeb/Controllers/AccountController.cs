using FrotaWeb.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Core;
using Core.Service;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace FrotaWeb.Controllers;

public class AccountController : Controller
{
    private readonly UserManager<UsuarioIdentity> userManager;
    private readonly IPessoaService pessoaService;
    private readonly FrotaContext context;
    public AccountController(FrotaContext frotaContext, UserManager<UsuarioIdentity> userManager, IPessoaService pessoaService)
    {
        this.userManager = userManager;
        this.pessoaService = pessoaService;
        this.context = frotaContext;
    }

    [HttpGet]
    [Route("Account/ConfirmEmail")]
    public async Task<ActionResult> ConfirmEmail(string userId, string token)
    {
        var user = await userManager.FindByIdAsync(userId);
        if (user == null)
        {
            return NotFound("Usuário não encontrado.");
        }

        // Verificar se o e-mail já foi confirmado
        if (user.EmailConfirmed)
        {
            return Redirect("/Identity/Account/Login");
        }

        var result = await pessoaService.ConfirmEmailAsync(userId, token);
        if (result.Succeeded)
        {
            return RedirectToAction(nameof(SetupPassword), new { userId });
        }
        return BadRequest("Erro ao confirmar o e-mail.");
    }

    [HttpGet]
    [Route("Account/SetupPassword")]
    public ActionResult SetupPassword(string userId)
    {
        if (string.IsNullOrEmpty(userId))
        {
            return Redirect("/Identity/Account/Login");
        }
        var model = new SetupPasswordViewModel { UserId = userId };
        return View(model);
    }

    [HttpPost]
    [Route("Account/SetupPassword")]
    public async Task<ActionResult> SetupPassword(SetupPasswordViewModel model)
    {
        if (!ModelState.IsValid)
        {
            return View(model);
        }

        var user = await userManager.FindByIdAsync(model.UserId);
        if (user == null)
        {
            return Redirect("/Identity/Account/Login");
        }

        var result = await userManager.AddPasswordAsync(user, model.Password);
        if (result.Succeeded)
        {
            return RedirectToAction("Index", "Home");
        }
        return View(model);
    }
}
