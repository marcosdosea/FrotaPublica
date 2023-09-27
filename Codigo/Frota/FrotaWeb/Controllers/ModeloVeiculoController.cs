using AutoMapper;
using FrotaWeb.Models;
using Core.Service;
using Microsoft.AspNetCore.Mvc;
using Service;
using Core;

namespace FrotaWeb.Controllers
{


    public class ModeloVeiculoController : Controller
    {

        private readonly IModeloVeiculoService _modeloveiculoservice;
        private readonly IMapper _mapper;


        /// <summary>
        /// Utilização do mapper no construtor da classe
        /// </summary>
        /// GET : ModeloVeiculoController
        /// <param name="modeloveiculoservice"></param>
        /// <param name="mapper"></param>
        public ModeloVeiculoController(IModeloVeiculoService modeloveiculoservice, IMapper mapper)
        {
            this._modeloveiculoservice = modeloveiculoservice;
            this._mapper = mapper;
        }


        /// <summary>
        /// Criação do método Index e Inicialização da View
        /// GET : ModeloVeiculoController
        /// </summary>
        /// <returns></returns>
        public ActionResult Index()
        {
            var listaModelVeiculos = _modeloveiculoservice.GetAll();
            var ModelVeiculos = _mapper.Map<List<ModeloVeiculoViewModel>>(listaModelVeiculos);
            return View(ModelVeiculos);
        }

        /// <summary>
        /// GET : ModeloVeiculoController
        /// </summary>
        /// <returns></returns>
        public ActionResult Create()
        {
            return View();
        }

        /// <summary>
        ///  POST : ModeloVeiculoController/Create
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(ModeloVeiculoViewModel model)
        {
            if (ModelState.IsValid)
            {
                var entity = _mapper.Map<Modeloveiculo>(model);
                _modeloveiculoservice.Create(entity);
            }
            return RedirectToAction(nameof(Index));
        }

        /// <summary>
        /// GET : ModeloVeiculoController/Details
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public ActionResult Details(uint id)
        {
            var entity = _modeloveiculoservice.Get(id);
            var entityModel = _mapper.Map<Modeloveiculo>(entity);
            return View(entityModel);
        }

        /// <summary>
        ///  GET : ModeloVeiculoController/Edit
        /// </summary>
        /// <returns></returns>
        public ActionResult Edit(uint id)
        {
            var entity = _modeloveiculoservice.Get(id);
            var entityModel = _mapper.Map<Modeloveiculo>(entity);
            return View(entityModel);
        }

        public ActionResult  Delete()
        {
            return View();
        }



    }
}
