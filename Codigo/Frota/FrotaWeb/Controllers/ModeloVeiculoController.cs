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



    }
}
