using AutoMapper;
using Core;
using Core.Service;
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

        public SolicitacaoManutencaoController(ISolicitacaoManutencaoService service, IMapper mapper, IVeiculoService veiculoService)
        {
            this.service = service;
            _mapper = mapper;
            this.veiculoService = veiculoService;
        }


        // GET: SolicitacaomanutencaoController.cs
        public ActionResult Index()
        {
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
            if (idFrota == 0)
            {
                return Redirect("/Identity/Account/Login");
            }
            var listaSolicitacoes = service.GetAll(idFrota);
            var listaSolicitacoesModel = _mapper.Map<List<SolicitacaoManutencaoViewModel>>(listaSolicitacoes);

            return View(listaSolicitacoesModel);
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
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
            ViewData["Veiculos"] = veiculoService.GetVeiculoDTO(idFrota);
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
                }
                catch (ServiceException exception)
                {
                    ViewData["Veiculos"] = veiculoService.GetVeiculoDTO(idFrota);
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
                }
                catch (ServiceException exception)
                {
                    ViewData["Veiculos"] = veiculoService.GetVeiculoDTO(idFrota);
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
            service.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}

