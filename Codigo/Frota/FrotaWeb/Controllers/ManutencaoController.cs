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
    [Authorize(Roles = "Gestor, Mecânico")]
    public class ManutencaoController : Controller
    {
        private readonly IManutencaoService manutencaoService;
        private readonly IMapper mapper;
        private readonly IVeiculoService veiculoService;
        private readonly IPessoaService pessoaService;
        private readonly IFornecedorService fornecedorService;

        public ManutencaoController(IManutencaoService manutencaoService, IMapper mapper, IVeiculoService veiculoService, IPessoaService pessoaService, IFornecedorService fornecedorService)
        {
            this.manutencaoService = manutencaoService;
            this.mapper = mapper;
            this.veiculoService = veiculoService;
            this.pessoaService = pessoaService;
            this.fornecedorService = fornecedorService;
        }

        // GET: ManutencaoController
        [Route("Manutencao/Index/{page}")]
        [Route("Manutencao/{page}")]
        [Route("Manutencao")]
        public ActionResult Index([FromRoute]int page = 0, [FromQuery] uint? idVeiculo = null)
        {
            uint.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            int length = 15;

            var veiculos = veiculoService.GetVeiculoDTO((int)idFrota);
            ViewData["Veiculos"] = veiculos;
            ViewBag.IdVeiculoSelecionado = idVeiculo;


            var query = manutencaoService.GetAll(idFrota);
            if (idVeiculo.HasValue)
            {
                query = query.Where(m => m.IdVeiculo == idVeiculo.Value);
            }

            var totalManutencoes = query.Count();
            var listaManutencoes = query
                                    .Skip(page * length)
                                    .Take(length)
                                    .ToList();

            var totalPages = (int)Math.Ceiling((double)totalManutencoes / length);

            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = totalPages;
            var listaManutencaoViewModel = mapper.Map<List<ManutencaoViewModel>>(listaManutencoes);
            foreach (var item in listaManutencaoViewModel)
            {
                item.PlacaVeiculo = veiculoService.GetPlacaVeiculo(item.IdVeiculo);
                item.NomeResponsavel = pessoaService.GetNomePessoa(item.IdResponsavel);
            }
            return View(listaManutencaoViewModel);
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
                    manutencaoService.Create(manutencao);
                    PopupHelper.AddPopup(this, type: "success", title: "Operação concluída", message: "A manutenção foi cadastrada com sucesso.");
                }
                catch (ServiceException exception)
                {
                    PopupHelper.AddPopup(this, type: "warning", title: "Operação não realizada", message: "Houveram inconsistências nos dados informados.");
                    ModelState.AddModelError(exception.AtributoError!, "Esse dado já foi utilizado em um cadastro existente");
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
                    PopupHelper.AddPopup(this, type: "success", title: "Operação concluída", message: "As alterações foram salvas com sucesso.");
                }
                catch (ServiceException exception)
                {
                    PopupHelper.AddPopup(this, type: "warning", title: "Operação não realizada", message: "Houveram inconsistências nos dados informados.");
                    ModelState.AddModelError(exception.AtributoError!, "Esse dado já foi utilizado em um cadastro existente");
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
                PopupHelper.AddPopup(this, type: "success", title: "Operação concluída", message: "O registro foi removido com sucesso.");
            }
            catch (ServiceException exception)
            {
                PopupHelper.AddPopup(this, type: "error", title: "Operação mal sucedida", message: "Não foi possível remover o registro.");
                return View(manutencaoViewModel);
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
