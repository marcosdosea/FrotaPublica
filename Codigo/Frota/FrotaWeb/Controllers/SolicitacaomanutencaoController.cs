using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{

    [Authorize]
    public class SolicitacaomanutencaoController : Controller
    {
        private readonly ISolicitacaomanutencaoService _service;
        private readonly IMapper _mapper;

        public SolicitacaomanutencaoController(ISolicitacaomanutencaoService service, IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
        }


        // GET: SolicitacaomanutencaoController.cs
        public ActionResult Index()
        {
            var listaSolicitacoes = _service.GetAll();
            var listaSolicitacoesModel = _mapper.Map<List<SolicitacaomanutencaoViewModel>>(listaSolicitacoes);

            return View(listaSolicitacoesModel);
        }

        // GET: SolicitacaomanutencaoController.cs/Details/5
        public ActionResult Details(uint id)
        {
            var solicitacao = _service.Get(id);
            var solicitacaoModel = _mapper.Map<SolicitacaomanutencaoViewModel>(solicitacao);

            return View(solicitacaoModel);
        }

        // GET: SolicitacaomanutencaoController.cs/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: SolicitacaomanutencaoController.cs/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(SolicitacaomanutencaoViewModel solicitacaoModel)
        {
            if (ModelState.IsValid) {
                var solicitacao = _mapper.Map<Solicitacaomanutencao>(solicitacaoModel);

                _service.Create(solicitacao);
            }

            return RedirectToAction(nameof(Index));
        }

        // GET: SolicitacaomanutencaoController.cs/Edit/5
        public ActionResult Edit(uint id)
        {
            var solicitacao = _service.Get(id);
            var solicitacaoModel = _mapper.Map<SolicitacaomanutencaoViewModel>(solicitacao);

            return View(solicitacaoModel);
        }

        // POST: SolicitacaomanutencaoController.cs/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, SolicitacaomanutencaoViewModel solicitacaoModel)
        {
            if (ModelState.IsValid) {
                var solicitacao = _mapper.Map<Solicitacaomanutencao>(solicitacaoModel);

                _service.Edit(solicitacao);
            }

            return RedirectToAction(nameof(Index));
        }

        // GET: SolicitacaomanutencaoController.cs/Delete/5
        public ActionResult Delete(uint id)
        {
            var solicitacao = _service.Get(id);
            var solicitacaoModel = _mapper.Map<SolicitacaomanutencaoViewModel>(solicitacao);

            return View(solicitacaoModel);
        }

        // POST: SolicitacaomanutencaoController.cs/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, SolicitacaomanutencaoViewModel solicitacaoModel)
        {
            _service.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}

