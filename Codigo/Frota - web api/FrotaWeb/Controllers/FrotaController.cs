using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{

    [Authorize(Roles = "Administrador")]
    public class FrotaController : Controller
    {

        private readonly IFrotaService frotaService;
        private readonly IMapper mapper;

        public FrotaController(IFrotaService frotaService, IMapper mapper)
        {
            this.frotaService = frotaService;
            this.mapper = mapper;
        }

        // GET: FrotaController
        public ActionResult Index()
        {
            var listaFrotas = frotaService.GetAll();
            var listaFrotasModel = mapper.Map<List<FrotaViewModel>>(listaFrotas);
            return View(listaFrotasModel);
        }

        // GET: FrotaController/Details/5
        public ActionResult Details(uint id)
        {
            Frotum frota = frotaService.Get((int)id);
            var frotaModel = mapper.Map<FrotaViewModel>(frota);
            return View(frotaModel);
        }

        // GET: FrotaController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: FrotaController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(FrotaViewModel frotaModel)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var frota = mapper.Map<Frotum>(frotaModel);
                    frotaService.Create(frota);
                }
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }

        // GET: FrotaController/Edit/5
        [HttpGet]
        public ActionResult Edit(uint id)
        {
            var frota = frotaService.Get((int)id);
            var frotaModel = mapper.Map<FrotaViewModel>(frota);
            return View(frotaModel);
        }

        // POST: FrotaController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int id, FrotaViewModel frotaModel)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var frota = mapper.Map<Frotum>(frotaModel);
                    frotaService.Edit(frota);
                }
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }

        // GET: FrotaController/Delete/5
        [HttpGet]
        public ActionResult Delete(uint id)
        {
            Frotum frota = frotaService.Get((int)id);
            var frotaModel = mapper.Map<FrotaViewModel>(frota);
            return View(frotaModel);
        }

        // POST: FrotaController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, FrotaViewModel frotaModel)
        {
            try
            {
                frotaService.Delete((int)id);
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }
    }
}
