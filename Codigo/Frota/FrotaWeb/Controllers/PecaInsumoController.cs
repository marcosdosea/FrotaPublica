using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{
    public class PecaInsumoController : Controller
    {
        private readonly IPecaInsumoService _pecaInsumoService;
        private readonly IMapper _mapper;

        public PecaInsumoController(IPecaInsumoService pecaInsumoService, IMapper mapper)
        {
            _pecaInsumoService = pecaInsumoService;
            _mapper = mapper;
        }
        // GET: PecaInsumoController
        public ActionResult Index()
        {
            var listaPeca = _pecaInsumoService.GetAll();
            var listaPecaModel = _mapper.Map<List<PecaInsumoViewModel>>(listaPeca);
            return View(listaPecaModel);
        }

        // GET: PecaInsumoController/Details/5
        public ActionResult Details(uint id)
        {
            Pecainsumo pecainsumo = _pecaInsumoService.Get(id);
            PecaInsumoViewModel pecainsumoModel = _mapper.Map<PecaInsumoViewModel>(pecainsumo);
            return View(pecainsumoModel);
        }

        // GET: PecaInsumoController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: PecaInsumoController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(PecaInsumoViewModel model)
        {
            if (ModelState.IsValid)
            {
                var peca = _mapper.Map<Pecainsumo>(model);
                _pecaInsumoService.Create(peca);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: PecaInsumoController/Edit/5
        public ActionResult Edit(uint id)
        {
            Pecainsumo pecainsumo = _pecaInsumoService.Get(id);
            PecaInsumoViewModel pecaInsumoViewModel = _mapper.Map<PecaInsumoViewModel>(pecainsumo);
            return View(pecaInsumoViewModel);
        }

        // POST: PecaInsumoController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, PecaInsumoViewModel model)
        {
            if (ModelState.IsValid)
            {
                var peca = _mapper.Map<Pecainsumo>(model);
                _pecaInsumoService.Edit(peca);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: PecaInsumoController/Delete/5
        public ActionResult Delete(uint id)
        {
            Pecainsumo pecainsumo = _pecaInsumoService.Get(id);
            PecaInsumoViewModel pecaInsumoViewModel = _mapper.Map<PecaInsumoViewModel>(pecainsumo);
            return View(pecaInsumoViewModel);
        }

        // POST: PecaInsumoController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, PecaInsumoViewModel model)
        {
            _pecaInsumoService.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
