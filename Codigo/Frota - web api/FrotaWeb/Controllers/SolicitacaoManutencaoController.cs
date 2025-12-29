using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Helpers;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{

    [Authorize(Roles = "Gestor, Motorista")]
    public class SolicitacaoManutencaoController : Controller
    {
        private readonly ISolicitacaoManutencaoService service;
        private readonly IMapper _mapper;
        private readonly IVeiculoService veiculoService;
        private readonly IPessoaService pessoaService;

        public SolicitacaoManutencaoController(ISolicitacaoManutencaoService service, IMapper mapper, IVeiculoService veiculoService, IPessoaService pessoaService)
        {
            this.service = service;
            _mapper = mapper;
            this.veiculoService = veiculoService;
            this.pessoaService = pessoaService;
        }


        // GET: SolicitacaomanutencaoController.cs
        [Route("SolicitacaoManutencao/Index/{page}")]
        [Route("SolicitacaoManutencao/Index")]
        [Route("SolicitacaoManutencao/{page}")]
        [Route("SolicitacaoManutencao")]
        public ActionResult Index([FromRoute] int page = 0, [FromQuery] uint? idVeiculo = null)
        {
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);

            // Obter todos os veículos para o dropdown
            var veiculos = veiculoService.GetVeiculoDTO(idFrota);
            ViewData["Veiculos"] = veiculos;
            ViewBag.IdVeiculoSelecionado = idVeiculo;

            // Aplicar filtro por veículo se necessário
            var query = service.GetAll(idFrota);
            if (idVeiculo.HasValue)
            {
                query = query.Where(s => s.IdVeiculo == idVeiculo.Value);
            }

            int itemsPerPage = 20;
            var allSolicitacoes = query.ToList();
            var totalItems = allSolicitacoes.Count;
            
            var pagedItems = allSolicitacoes
                .Skip(page * itemsPerPage)
                .Take(itemsPerPage)
                .ToList();

            var pagedResult = new PagedResult<SolicitacaoManutencaoViewModel>
            {
                Items = _mapper.Map<List<SolicitacaoManutencaoViewModel>>(pagedItems),
                CurrentPage = page,
                ItemsPerPage = itemsPerPage,
                TotalItems = totalItems,
                TotalPages = (int)Math.Ceiling((double)totalItems / itemsPerPage)
            };

            foreach (var item in pagedResult.Items)
            {
                item.PlacaVeiculo = veiculoService.GetPlacaVeiculo(item.IdVeiculo);
                item.NomePessoa = pessoaService.GetNomePessoa(item.IdPessoa);
            }

            ViewBag.PagedResult = pagedResult;
            return View(pagedResult.Items);
        }

        // GET: SolicitacaomanutencaoController.cs/Details/5
        public ActionResult Details(uint id)
        {
            var solicitacao = service.Get(id);
            var solicitacaoModel = _mapper.Map<SolicitacaoManutencaoViewModel>(solicitacao);

            return View(solicitacaoModel);
        }

        // GET: SolicitacaomanutencaoController.cs/Create
        public ActionResult Create()
        {
            var frotaIdClaim = User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId");
            if (frotaIdClaim == null || !int.TryParse(frotaIdClaim.Value, out int idFrota) || idFrota == 0)
            {
                return Redirect("/Identity/Account/Login");
            }
            ViewData["Veiculos"] = veiculoService.GetVeiculoDTO(idFrota);
            ViewData["Pessoas"] = pessoaService.GetAllOrdemAlfabetica(idFrota);
            return View();
        }

        // POST: SolicitacaomanutencaoController.cs/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(SolicitacaoManutencaoViewModel solicitacaoModel)
        {
            if (ModelState.IsValid) {
                int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
                try
                {
                    var solicitacao = _mapper.Map<Solicitacaomanutencao>(solicitacaoModel);
                    service.Create(solicitacao, idFrota);
                    PopupHelper.AddPopup(this, type: "success", title: "Operação concluída", message: "A solicitação foi cadastrada com sucesso!");
                }
                catch (ServiceException exception)
                {
                    PopupHelper.AddPopup(this, type: "warning", title: "Operação não realizada", message: "Houveram inconsistências nos dados informados.");
                    ModelState.AddModelError(exception.AtributoError!, "Esse dado já foi utilizado em um cadastro existente");
                    ViewData["Veiculos"] = veiculoService.GetVeiculoDTO(idFrota);
                    ViewData["Pessoas"] = pessoaService.GetAllOrdemAlfabetica(idFrota);
                    return View(solicitacaoModel);
                }
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: SolicitacaomanutencaoController.cs/Edit/5
        public ActionResult Edit(uint id)
        {
            var solicitacao = service.Get(id);
            var solicitacaoModel = _mapper.Map<SolicitacaoManutencaoViewModel>(solicitacao);
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
            ViewData["Veiculos"] = veiculoService.GetVeiculoDTO(idFrota);
            ViewData["Pessoas"] = pessoaService.GetAllOrdemAlfabetica(idFrota);
            return View(solicitacaoModel);
        }

        // POST: SolicitacaomanutencaoController.cs/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, SolicitacaoManutencaoViewModel solicitacaoModel)
        {
            if (ModelState.IsValid) {
                int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
                try
                {
                    var solicitacao = _mapper.Map<Solicitacaomanutencao>(solicitacaoModel);
                    service.Edit(solicitacao, idFrota);
                    PopupHelper.AddPopup(this, type: "success", title: "Operação concluída", message: "As alterações foram salvas com sucesso.");
                }
                catch (ServiceException exception)
                {
                    PopupHelper.AddPopup(this, type: "warning", title: "Operação não realizada", message: "Houveram inconsistências nos dados informados.");
                    ModelState.AddModelError(exception.AtributoError!, "Esse dado já foi utilizado em um cadastro existente");
                    ViewData["Veiculos"] = veiculoService.GetVeiculoDTO(idFrota);
                    ViewData["Pessoas"] = pessoaService.GetAllOrdemAlfabetica(idFrota);
                    return View(solicitacaoModel);
                }
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: SolicitacaomanutencaoController.cs/Delete/5
        public ActionResult Delete(uint id)
        {
            var solicitacao = service.Get(id);
            var solicitacaoModel = _mapper.Map<SolicitacaoManutencaoViewModel>(solicitacao);

            return View(solicitacaoModel);
        }

        // POST: SolicitacaomanutencaoController.cs/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, SolicitacaoManutencaoViewModel solicitacaoModel)
        {
            try
            {
                service.Delete(id);
                PopupHelper.AddPopup(this, type: "success", title: "Operação concluída", message: "O registro foi removido com sucesso.");
            }
            catch (ServiceException exception)
            {
                PopupHelper.AddPopup(this, type: "error", title: "Operação mal sucedida", message: "Não foi possível remover o registro.");
                return View(solicitacaoModel);
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
