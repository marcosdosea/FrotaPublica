using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Service;

namespace FrotaWeb.Controllers
{
    [Authorize(Roles = "Mecânico")]
    public class MecanicoController : Controller
    {
        private readonly IManutencaoService manutencaoService;
        private readonly IVeiculoService veiculoService;
        private readonly IUnidadeAdministrativaService unidadeService;
        private readonly IValidadePecaInsumoService validadeService;
        private readonly IPessoaService pessoaService;
        private readonly IMapper mapper;
        private readonly FrotaContext context;

        public MecanicoController(
            IManutencaoService manutencaoService,
            IVeiculoService veiculoService,
            IUnidadeAdministrativaService unidadeService,
            IValidadePecaInsumoService validadeService,
            IPessoaService pessoaService,
            IMapper mapper,
            FrotaContext context)
        {
            this.manutencaoService = manutencaoService;
            this.veiculoService = veiculoService;
            this.unidadeService = unidadeService;
            this.validadeService = validadeService;
            this.pessoaService = pessoaService;
            this.mapper = mapper;
            this.context = context;
        }

        // GET: Mecanico/Index
        public IActionResult Index()
        {
            uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            if (idFrota == 0)
            {
                return Redirect("/Identity/Account/Login");
            }

            // Obter unidade administrativa do mecânico
            var pessoaId = pessoaService.GetPessoaIdUser();
            var pessoa = context.Pessoas
                .Include(p => p.IdunidadeAdministrativaNavigation)
                .FirstOrDefault(p => p.Id == pessoaId);

            uint? idUnidade = pessoa?.IdunidadeAdministrativa;

            // Obter alertas de validade da unidade
            var alertas = new List<AlertaValidade>();
            if (idUnidade.HasValue)
            {
                alertas = validadeService.ObterAlertasUnidadeAdministrativa(idUnidade.Value).ToList();
            }

            // Obter manutenções da unidade
            var manutencoes = new List<Manutencao>();
            if (idUnidade.HasValue)
            {
                var veiculosUnidade = context.Veiculos
                    .Where(v => v.IdUnidadeAdministrativa == idUnidade.Value && v.IdFrota == idFrota)
                    .Select(v => v.Id)
                    .ToList();

                manutencoes = context.Manutencaos
                    .Include(m => m.IdVeiculoNavigation)
                    .Include(m => m.IdResponsavelNavigation)
                    .Where(m => veiculosUnidade.Contains(m.IdVeiculo))
                    .OrderByDescending(m => m.DataHora)
                    .ToList();
            }

            ViewBag.Alertas = alertas;
            ViewBag.Manutencoes = manutencoes;
            ViewBag.IdUnidade = idUnidade;
            ViewBag.NomeUnidade = pessoa?.IdunidadeAdministrativaNavigation?.Nome ?? "N/A";

            return View();
        }

        // GET: Mecanico/Alertas
        [HttpGet]
        public IActionResult Alertas()
        {
            uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            if (idFrota == 0)
            {
                return Json(new List<AlertaValidade>());
            }

            var pessoaId = pessoaService.GetPessoaIdUser();
            var pessoa = context.Pessoas
                .Include(p => p.IdunidadeAdministrativaNavigation)
                .FirstOrDefault(p => p.Id == pessoaId);

            if (pessoa?.IdunidadeAdministrativa == null)
            {
                return Json(new List<AlertaValidade>());
            }

            var alertas = validadeService.ObterAlertasUnidadeAdministrativa((uint)pessoa.IdunidadeAdministrativa);
            return Json(alertas);
        }
    }
}

