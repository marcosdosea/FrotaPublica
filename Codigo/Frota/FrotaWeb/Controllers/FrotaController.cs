using AutoMapper;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{
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
        public ActionResult Details(int id)
        {
            return View();
        }

        // GET: FrotaController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: FrotaController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }

        // GET: FrotaController/Edit/5
        public ActionResult Edit(int id)
        {
            return View();
        }

        // POST: FrotaController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int id, IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }

        // GET: FrotaController/Delete/5
        public ActionResult Delete(int id)
        {
            return View();
        }

        // POST: FrotaController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id, IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }
    }
}
