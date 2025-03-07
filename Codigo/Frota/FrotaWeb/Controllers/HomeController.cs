using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using Microsoft.AspNetCore.Identity;
using System.Threading.Tasks;
using System.Security.Claims;
using Core;
using Core.Service;
using System.Data;

namespace FrotaWeb.Controllers;

[Authorize]
public class HomeController : Controller
{
    private readonly ILogger<HomeController> logger;
    private readonly UserManager<UsuarioIdentity> userManager; // Injete o UserManager
    private readonly IPessoaService pessoaService;

    public HomeController(ILogger<HomeController> logger, UserManager<UsuarioIdentity> userManager, IPessoaService pessoaService)
    {
        this.logger = logger;
        this.userManager = userManager;
        this.pessoaService = pessoaService;
    }

    public async Task<IActionResult> Index()
    {
        var viewModel = new HomeViewModel();
        var user = await userManager.GetUserAsync(User);
        viewModel.NameUser = pessoaService.GetNomePessoa(pessoaService.GetPessoaIdUser());
        var roles = await userManager.GetRolesAsync(user);
        string userRole = roles.FirstOrDefault();
        viewModel.UserType = userRole;
        //inicializar uma lista de lembretes manualmente que é uma lista de strings
        viewModel.Lembretes = new List<string> { "Ação de cadastro pendente.", "Verifique a nova política de privacidade"};
        viewModel.CoutLembretes = viewModel.Lembretes.Count();

        return View(viewModel);
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}