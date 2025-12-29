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
using Service;

namespace FrotaWeb.Controllers;

[Authorize]
public class HomeController : Controller
{
    private readonly ILogger<HomeController> logger;
    private readonly UserManager<UsuarioIdentity> userManager;
    private readonly IPercursoService percursoService;
    private readonly IPessoaService pessoaService;
    private readonly IFrotaService frotaService;
    private readonly IVeiculoService veiculoService;
    private readonly IAbastecimentoService abastecimentoService;
    private readonly IManutencaoService manutencaoService;
    private readonly IValidadePecaInsumoService validadeService;
    private readonly IUnidadeAdministrativaService unidadeService;

    public HomeController(ILogger<HomeController> logger, UserManager<UsuarioIdentity> userManager, IPessoaService pessoaService, IPercursoService percursoService, IFrotaService frotaService, IVeiculoService veiculoService, IAbastecimentoService abastecimentoService, IManutencaoService manutencaoService, IValidadePecaInsumoService validadeService, IUnidadeAdministrativaService unidadeService)
    {
        this.logger = logger;
        this.userManager = userManager;
        this.pessoaService = pessoaService;
        this.percursoService = percursoService;
        this.frotaService = frotaService;
        this.veiculoService = veiculoService;
        this.abastecimentoService = abastecimentoService;
        this.manutencaoService = manutencaoService;
        this.validadeService = validadeService;
        this.unidadeService = unidadeService;
    }

    public async Task<IActionResult> Index()
    {
        var viewModel = new HomeViewModel();
        var user = await userManager.GetUserAsync(User);
        viewModel.NameUser = pessoaService.GetNomePessoa(pessoaService.GetPessoaIdUser());
        var roles = await userManager.GetRolesAsync(user);
        string userRole = roles.FirstOrDefault();
        if(userRole == "Motorista")
        {
            uint idPercurso = pessoaService.EmPercurso();
            if(idPercurso == 0)
            {
                return RedirectToAction("VeiculosDisponiveis", "Veiculo");
            }
            else
            {
                uint idVeiculoDoPercurso = percursoService.ObterVeiculoDePercurso(idPercurso);
                return RedirectToAction("Gerenciamento", "Veiculo", new { idPercurso = idPercurso, idVeiculo = idVeiculoDoPercurso });
            }
        }
        viewModel.UserType = userRole;
        
        // Inicializar lembretes e estatísticas baseados no papel do usuário
        var lembretes = new List<string>();
        
        if (userRole == "Administrador")
        {
            // Estatísticas para Administrador
            viewModel.TotalFrotas = frotaService.GetAll().Count();
            
            // Contar veículos de todas as frotas
            var todasFrotas = frotaService.GetAll().ToList();
            int totalVeiculos = 0;
            foreach (var frota in todasFrotas)
            {
                totalVeiculos += veiculoService.GetAll((uint)frota.Id).Count();
            }
            viewModel.TotalVeiculos = totalVeiculos;
            
            // Contar pessoas de todas as frotas
            int totalPessoas = 0;
            foreach (var frota in todasFrotas)
            {
                totalPessoas += pessoaService.GetAllOrdemAlfabetica((int)frota.Id).Count();
            }
            viewModel.TotalPessoas = totalPessoas;
            
            // Contar unidades administrativas
            int totalUnidades = 0;
            foreach (var frota in todasFrotas)
            {
                totalUnidades += unidadeService.GetAll((uint)frota.Id).Count();
            }
            viewModel.TotalUnidadesAdministrativas = totalUnidades;
            
            // Lembretes específicos para administrador
            lembretes.Add("Verifique a nova política de privacidade");
            
            // Adicionar alertas de validade de todas as frotas
            var alertasTotais = new List<AlertaValidade>();
            foreach (var frota in todasFrotas)
            {
                alertasTotais.AddRange(validadeService.ObterAlertasFrota((uint)frota.Id));
            }
            viewModel.TotalAlertasValidade = alertasTotais.Count(a => a.TipoAlerta == "Urgente");
            
            foreach (var alerta in alertasTotais.Take(5))
            {
                lembretes.Add(alerta.Mensagem);
            }
        }
        else if (userRole == "Gestor")
        {
            var frotaIdClaim = User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId");
            if (frotaIdClaim != null && uint.TryParse(frotaIdClaim.Value, out uint idFrota) && idFrota > 0)
            {
                // Estatísticas para Gestor
                viewModel.TotalVeiculos = veiculoService.GetAll(idFrota).Count();
                viewModel.TotalAbastecimentos = abastecimentoService.GetAll(idFrota).Count();
                viewModel.TotalManutencoes = manutencaoService.GetAll(idFrota).Count();
                viewModel.TotalVistorias = 0; // Adicionar serviço de vistoria se necessário
                viewModel.TotalPercursos = percursoService.GetAll().Count();
                
                var alertas = validadeService.ObterAlertasFrota(idFrota);
                viewModel.TotalAlertasValidade = alertas.Count(a => a.TipoAlerta == "Urgente");
                
                lembretes.Add("Verifique a nova política de privacidade");
                foreach (var alerta in alertas.Take(5))
                {
                    lembretes.Add(alerta.Mensagem);
                }
            }
        }
        else
        {
            lembretes.Add("Ação de cadastro pendente.");
            lembretes.Add("Verifique a nova política de privacidade");
        }
        
        viewModel.Lembretes = lembretes;
        viewModel.CoutLembretes = lembretes.Count();

        return View(viewModel);
    }

    [AllowAnonymous]
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
