using AutoMapper;
using FrotaWeb.Models;
using Core.Service;
using Microsoft.AspNetCore.Mvc;
using Core;
using Microsoft.AspNetCore.Authorization;

namespace FrotaWeb.Controllers
{
    [Authorize(Roles = "Administrador")]
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
        [Route("ModeloVeiculo/Index/{page}")]
        [Route("ModeloVeiculo/{page}")]
        [Route("ModeloVeiculo")]
        public ActionResult Index([FromRoute] int page = 0)
        {
            uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            if (idFrota == 0)
            {
                return Redirect("/Identity/Account/Login");
            }
            
            int itemsPerPage = 20;
            var allModelos = _modeloveiculoservice.GetAll(idFrota).ToList();
            var totalItems = allModelos.Count;
            
            var pagedItems = allModelos
                .Skip(page * itemsPerPage)
                .Take(itemsPerPage)
                .ToList();
            
            var pagedResult = new PagedResult<ModeloVeiculoViewModel>
            {
                Items = _mapper.Map<List<ModeloVeiculoViewModel>>(pagedItems),
                CurrentPage = page,
                ItemsPerPage = itemsPerPage,
                TotalItems = totalItems,
                TotalPages = (int)Math.Ceiling((double)totalItems / itemsPerPage)
            };

            ViewBag.PagedResult = pagedResult;
            return View(pagedResult.Items);
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
                uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
                if (idFrota == 0)
                {
                    return Redirect("/Identity/Account/Login");
                }
                var modeloVeiculo = _mapper.Map<Modeloveiculo>(model);
                modeloVeiculo.IdFrota = idFrota;
                _modeloveiculoservice.Create(modeloVeiculo);
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
            var entityModel = _mapper.Map<ModeloVeiculoViewModel>(entity);
            return View(entityModel);
        }

        /// <summary>
        ///  GET : ModeloVeiculoController/Edit
        /// </summary>
        /// <returns></returns>
        public ActionResult Edit(uint id)
        {
            var entity = _modeloveiculoservice.Get(id);
            var entityModel = _mapper.Map<ModeloVeiculoViewModel>(entity);
            return View(entityModel);
        }

        /// <summary>
        ///  POST : ModeloVeiculoController/Edit
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(ModeloVeiculoViewModel model)
        {
            if (ModelState.IsValid)
            {
                var entity = _mapper.Map<Modeloveiculo>(model);
                _modeloveiculoservice.Create(entity);
            }
            return RedirectToAction(nameof(Index));
        }

        /// <summary>
        /// GET: ModeloVeiculoController/Delete
        /// </summary>
        /// <returns></returns>
        public ActionResult Delete(uint id)
        {
            var entity = _modeloveiculoservice.Get(id);
            var entityModel = _mapper.Map<ModeloVeiculoViewModel>(entity);
            return View(entityModel);
        }


        /// <summary>
        /// POST: ModeloVeiculoController/Delete
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(ModeloVeiculoViewModel model, uint id)
        {
            _modeloveiculoservice.Delete(id);
            return RedirectToAction(nameof(Index));
        }

    }
}
