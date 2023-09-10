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
            var peca = _pecaInsumoService.GetAll();
            var listaModel = _mapper.Map<List<PecaInsumoViewModel>>(peca);
            return View(listaModel);
        }

        // GET: PecaInsumoController/Details/5
        public ActionResult Details(uint idPeca)
        {
            var entity = _pecaInsumoService.Get(idPeca);
            var entityModel = _mapper.Map<PecaInsumoViewModel>(entity);
            return View(entityModel);
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
                var entity = _mapper.Map<Pecainsumo>(model);
                _pecaInsumoService.Create(entity);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: PecaInsumoController/Edit/5
        public ActionResult Edit(uint idPeca)
        {
            var entity = _pecaInsumoService.Get(idPeca);
            var entityModel = _mapper.Map<PecaInsumoViewModel>(entity);
            return View(entityModel);
        }

        // POST: PecaInsumoController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit( IPecaInsumoService model)
        {
            if (ModelState.IsValid)
            {
                var entity = _mapper.Map<Pecainsumo>(model);
                _pecaInsumoService.Edit(entity);
            }
            
                return RedirectToAction(nameof(Index));
            
           
        }

        // GET: PecaInsumoController/Delete/5
        public ActionResult Delete(uint idPeca)
        {
            var entity = _pecaInsumoService.Get(idPeca);
            var entityModel = _mapper.Map<PecaInsumoViewModel>(entity);
            return View();
        }

        // POST: PecaInsumoController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint idPeca, PecaInsumoViewModel model)
        {
            _pecaInsumoService.Delete(idPeca);
            return RedirectToAction(nameof(Index));
        }
    }
}
