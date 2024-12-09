using AutoMapper;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Mvc;
using Core.Service;
using Core;
using Microsoft.AspNetCore.Authorization;

namespace FrotaWeb.Controllers
{
    [Authorize(Roles = "Administrador")]
    public class MarcaPecaInsumoController : Controller
    {
        private readonly IMarcaPecaInsumoService _marcaPecaInsumoService;
        private readonly IMapper _mapper;

        public MarcaPecaInsumoController(IMarcaPecaInsumoService marcaPecaInsumoService, IMapper mapper)
        {
            _marcaPecaInsumoService = marcaPecaInsumoService;
            _mapper = mapper;
        }

        // GET: MarcaPecaInsumoController
        public ActionResult Index()
        {
            var lista = _marcaPecaInsumoService.GetAll();
            var listaModel = _mapper.Map<List<MarcaPecaInsumoViewModel>>(lista);
            return View(listaModel);
        }

        // GET: MarcaPecaInsumoController/Details/5
        public ActionResult Details(uint id)
        {
            var entity = _marcaPecaInsumoService.Get(id);
            var entityModel = _mapper.Map<MarcaPecaInsumoViewModel>(entity);
            return View(entityModel);
        }

        // GET: MarcaPecaInsumoController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: MarcaPecaInsumoController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(MarcaPecaInsumoViewModel model)
        {
            if (ModelState.IsValid)
            {
                var entity = _mapper.Map<Marcapecainsumo>(model);
                _marcaPecaInsumoService.Create(entity);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: MarcaPecaInsumoController/Edit/5
        public ActionResult Edit(uint id)
        {
            var entity = _marcaPecaInsumoService.Get(id);
            var entityModel = _mapper.Map<MarcaPecaInsumoViewModel>(entity);
            return View(entityModel);
        }

        // POST: MarcaPecaInsumoController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(MarcaPecaInsumoViewModel model)
        {
            if (ModelState.IsValid)
            {
                var entity = _mapper.Map<Marcapecainsumo>(model);
                _marcaPecaInsumoService.Edit(entity);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: MarcaPecaInsumoController/Delete/5
        public ActionResult Delete(uint id)
        {
            var entity = _marcaPecaInsumoService.Get(id);
            var entityModel = _mapper.Map<MarcaPecaInsumoViewModel>(entity);
            return View(entityModel);
        }

        // POST: MarcaPecaInsumoController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, MarcaPecaInsumoViewModel model)
        {
            _marcaPecaInsumoService.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
