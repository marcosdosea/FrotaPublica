using AutoMapper;
using FrotaWeb.Models;
using Core.Service;
using Microsoft.AspNetCore.Mvc;
using Service;

namespace FrotaWeb.Controllers
{


    public class ModeloVeiculoController : Controller
    {

        private readonly IModeloVeiculoService _modeloveiculoservice;
        private readonly IMapper _mapper;


        /// <summary>
        /// Utilização do mapper no construtor da classe
        /// </summary>
        /// <param name="modeloveiculoservice"></param>
        /// <param name="mapper"></param>
        public ModeloVeiculoController(IModeloVeiculoService modeloveiculoservice, IMapper mapper)
        {
            this._modeloveiculoservice = modeloveiculoservice;
            this._mapper = mapper;
        }

        public IActionResult Index()
        {
            var listaModelVeiculos = _modeloveiculoservice.GetAll();
            var ModelVeiculos = _mapper.Map<List<ModeloVeiculoViewModel>>(listaModelVeiculos);
            return View(ModelVeiculos);
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
