using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Helpers;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Service;

namespace FrotaWeb.Controllers
{
    [Authorize(Roles = "Gestor, Mec�nico")]
    public class ManutencaoController : Controller
    {
        private readonly IManutencaoService manutencaoService;
        private readonly IMapper mapper;
        private readonly IVeiculoService veiculoService;
        private readonly IPessoaService pessoaService;
        private readonly IFornecedorService fornecedorService;
        private readonly IValidadePecaInsumoService validadeService;

        public ManutencaoController(IManutencaoService manutencaoService, IMapper mapper, IVeiculoService veiculoService, IPessoaService pessoaService, IFornecedorService fornecedorService, IValidadePecaInsumoService validadeService)
        {
            this.manutencaoService = manutencaoService;
            this.mapper = mapper;
            this.veiculoService = veiculoService;
            this.pessoaService = pessoaService;
            this.fornecedorService = fornecedorService;
            this.validadeService = validadeService;
        }

        // GET: ManutencaoController
        [Route("Manutencao/Index/{page}")]
        [Route("Manutencao/{page}")]
        [Route("Manutencao")]
        public ActionResult Index([FromRoute]int page = 0, [FromQuery] uint? idVeiculo = null)
        {
            uint.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            int itemsPerPage = 20;

            var veiculos = veiculoService.GetVeiculoDTO((int)idFrota);
            ViewData["Veiculos"] = veiculos;
            ViewBag.IdVeiculoSelecionado = idVeiculo;

            var query = manutencaoService.GetAll(idFrota);
            if (idVeiculo.HasValue)
            {
                query = query.Where(m => m.IdVeiculo == idVeiculo.Value);
            }

            var allManutencoes = query.ToList();
            var totalItems = allManutencoes.Count;
            
            var pagedItems = allManutencoes
                .Skip(page * itemsPerPage)
                .Take(itemsPerPage)
                .ToList();

            var pagedResult = new PagedResult<ManutencaoViewModel>
            {
                Items = mapper.Map<List<ManutencaoViewModel>>(pagedItems),
                CurrentPage = page,
                ItemsPerPage = itemsPerPage,
                TotalItems = totalItems,
                TotalPages = (int)Math.Ceiling((double)totalItems / itemsPerPage)
            };

            foreach (var item in pagedResult.Items)
            {
                item.PlacaVeiculo = veiculoService.GetPlacaVeiculo(item.IdVeiculo);
                item.NomeResponsavel = pessoaService.GetNomePessoa(item.IdResponsavel);
            }

            ViewBag.PagedResult = pagedResult;
            return View(pagedResult.Items);
        }

        // GET: ManutencaoController/Details/5
        public ActionResult Details(uint id)
        {
            var manutencao = manutencaoService.Get(id);
            var manutencaoViewModel = mapper.Map<ManutencaoViewModel>(manutencao);
            return View(manutencaoViewModel);
        }

        // GET: ManutencaoController/Create
        [Route("Manutencao/Create")]
        public ActionResult Create()
        {
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
            ViewData["Veiculos"] = veiculoService.GetVeiculoDTO(idFrota);
            ViewData["Pessoas"] = pessoaService.GetAllOrdemAlfabetica(idFrota);
            ViewData["Fornecedores"] = fornecedorService.GetAllOrdemAlfabetica(idFrota);
            return View();
        }

        // POST: ManutencaoController/Create
        [HttpPost]
        [Route("Manutencao/Create")]
        [ValidateAntiForgeryToken]
        public ActionResult Create(ManutencaoViewModel manutencaoViewModel)
        {
            if (ModelState.IsValid)
            {
                int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
                try
                {
                    var manutencao = mapper.Map<Manutencao>(manutencaoViewModel);
                    manutencao.IdFrota = (uint)idFrota;
                    var idManutencao = manutencaoService.Create(manutencao);
                    
                    // Atualizar validades de peças após manutenção
                    validadeService.AtualizarValidadeAposManutencao(idManutencao, manutencao.IdVeiculo);
                    PopupHelper.AddPopup(this, type: "success", title: "Opera��o conclu�da", message: "A manuten��o foi cadastrada com sucesso.");
                }
                catch (ServiceException exception)
                {
                    PopupHelper.AddPopup(this, type: "warning", title: "Opera��o n�o realizada", message: "Houveram inconsist�ncias nos dados informados.");
                    ModelState.AddModelError(exception.AtributoError!, "Esse dado j� foi utilizado em um cadastro existente");
                    ViewData["Veiculos"] = veiculoService.GetVeiculoDTO(idFrota);
                    ViewData["Pessoas"] = pessoaService.GetAllOrdemAlfabetica(idFrota);
                    ViewData["Fornecedores"] = fornecedorService.GetAllOrdemAlfabetica(idFrota);
                    return View(manutencaoViewModel);
                }
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: ManutencaoController/Edit/5
        public ActionResult Edit(uint id)
        {
            var manutencao = manutencaoService.Get(id);
            var manutencaoViewModel = mapper.Map<ManutencaoViewModel>(manutencao);
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
            ViewData["Veiculos"] = veiculoService.GetVeiculoDTO(idFrota);
            ViewData["Pessoas"] = pessoaService.GetAllOrdemAlfabetica(idFrota);
            ViewData["Fornecedores"] = fornecedorService.GetAllOrdemAlfabetica(idFrota);
            return View(manutencaoViewModel);
        }

        // POST: ManutencaoController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, ManutencaoViewModel manutencaoViewModel)
        {
            if (ModelState.IsValid)
            {
                int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
                try
                {
                    var manutencao = mapper.Map<Manutencao>(manutencaoViewModel);
                    manutencao.IdFrota = (uint)idFrota;
                    manutencaoService.Edit(manutencao);
                    PopupHelper.AddPopup(this, type: "success", title: "Opera��o conclu�da", message: "As altera��es foram salvas com sucesso.");
                }
                catch (ServiceException exception)
                {
                    PopupHelper.AddPopup(this, type: "warning", title: "Opera��o n�o realizada", message: "Houveram inconsist�ncias nos dados informados.");
                    ModelState.AddModelError(exception.AtributoError!, "Esse dado j� foi utilizado em um cadastro existente");
                    ViewData["Veiculos"] = veiculoService.GetVeiculoDTO(idFrota);
                    ViewData["Pessoas"] = pessoaService.GetAllOrdemAlfabetica(idFrota);
                    ViewData["Fornecedores"] = fornecedorService.GetAllOrdemAlfabetica(idFrota);
                    return View(manutencaoViewModel);
                }
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: ManutencaoController/Delete/5
        public ActionResult Delete(uint id)
        {
            var manutencao = manutencaoService.Get(id);
            var manutencaoViewModel = mapper.Map<ManutencaoViewModel>(manutencao);
            return View(manutencaoViewModel);
        }

        // POST: ManutencaoController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, ManutencaoViewModel manutencaoViewModel)
        {
            try
            {
                manutencaoService.Delete(id);
                PopupHelper.AddPopup(this, type: "success", title: "Opera��o conclu�da", message: "O registro foi removido com sucesso.");
            }
            catch (ServiceException exception)
            {
                PopupHelper.AddPopup(this, type: "error", title: "Opera��o mal sucedida", message: "N�o foi poss�vel remover o registro.");
                return View(manutencaoViewModel);
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
