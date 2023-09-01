using Microsoft.AspNetCore.Mvc;
using Service;

namespace FrotaWeb.Controllers
{
    public class MarcaPecaInsumoController : Controller
    {
        private readonly IMarcaPecaInsumoService _marcaPecaInsumoService;

        public MarcaPecaInsumoController(IMarcaPecaInsumoService marcaPecaInsumoService)
        {
            _marcaPecaInsumoService = marcaPecaInsumoService;
        }

        // GET: MarcaPecaInsumoController
        public ActionResult Index()
        {
            return View();
        }

        // GET: MarcaPecaInsumoController/Details/5
        public ActionResult Details(int id)
        {
            return View();
        }

        // GET: MarcaPecaInsumoController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: MarcaPecaInsumoController/Create
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

        // GET: MarcaPecaInsumoController/Edit/5
        public ActionResult Edit(int id)
        {
            return View();
        }

        // POST: MarcaPecaInsumoController/Edit/5
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

        // GET: MarcaPecaInsumoController/Delete/5
        public ActionResult Delete(int id)
        {
            return View();
        }

        // POST: MarcaPecaInsumoController/Delete/5
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
