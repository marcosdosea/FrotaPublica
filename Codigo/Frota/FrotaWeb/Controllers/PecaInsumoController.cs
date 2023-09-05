using Core.Service;
using Microsoft.AspNetCore.Mvc;
using System.Security.Cryptography.X509Certificates;

namespace FrotaWeb.Controllers
{
    public class PecaInsumoController
    {
        public class PecaIsumoController : Controller
        {
            private readonly IPecaInsumoService _pecaInsumoService;

            public PecaIsumoController(IPecaInsumoService pecaInsumoService)
            {
                _pecaInsumoService = pecaInsumoService; 
            }
            public ActionResult Index()
            {
                return View();
            }

            public ActionResult Details()
            {
                return View();
            }

            public ActionResult Create()
            {
                return View();
            }

            [HttpPost]
            [ValidateAntiForgeryToken]
            public ActionResult Create(IFormCollection collection)
            {
                {
                    return RedirectToAction(nameof(Index));
                }
            }
           
            public ActionResult Edit() 
            {
                return View();
            }

            [HttpPost]
            [ValidateAntiForgeryToken]
            public ActionResult Edit(IFormCollection collection) 
            {
                return RedirectToAction(nameof(Index));
            }

            public ActionResult Delete() 
            {
                return View();
            }
            [HttpPost]
            [ValidateAntiForgeryToken]
            public ActionResult Delete(IFormCollection collection)
            {
                return RedirectToAction(nameof(Index));
            }
        }

    }
}
