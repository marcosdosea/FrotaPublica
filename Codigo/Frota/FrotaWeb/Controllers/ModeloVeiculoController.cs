using Core.Service;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{


    public class ModeloVeiculoController : Controller
    {

        private readonly IModeloVeiculoService modeloveiculoservice;

        public ModeloVeiculoController(IModeloVeiculoService modeloveiculoservice)
        {
            this.modeloveiculoservice = modeloveiculoservice;
        }

        public IActionResult Index()
        {

            return View();
        }

        public IActionResult Create()
        {
            return View();
        }

        public IActionResult Edit()
        {
            return View();
        }

        public IActionResult  Delete()
        {
            return View();
        }



    }
}
