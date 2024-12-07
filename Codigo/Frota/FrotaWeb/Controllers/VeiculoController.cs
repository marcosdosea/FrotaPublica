using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{
    [Authorize(Roles = "Gestor")]
    public class VeiculoController : Controller
    {
        private readonly IVeiculoService veiculoService;
        private readonly IMapper mapper;
        private readonly IUnidadeAdministrativaService unidadeAdministrativaService;
		private readonly IFrotaService frotaService;
		private readonly IModeloVeiculoService modeloVeiculoService;

		public VeiculoController(IVeiculoService service, IMapper mapper, IUnidadeAdministrativaService unidadeAdministrativaService, IFrotaService frotaService, IModeloVeiculoService modeloVeiculoService)
        {
            this.veiculoService = service;
            this.mapper = mapper;
            this.unidadeAdministrativaService = unidadeAdministrativaService;
            this.frotaService = frotaService;
            this.modeloVeiculoService = modeloVeiculoService;
        }

        // GET: Veiculo
        public ActionResult Index()
        {
            var veiculos = veiculoService.GetAll();
            var veiculosViewModel = mapper.Map<List<VeiculoViewModel>>(veiculos);
            return View(veiculosViewModel);
        }

        // GET: Veiculo/Details/5
        public ActionResult Details(uint id)
        {
            var veiculo = veiculoService.Get(id);
            var veiculoViewModel = mapper.Map<VeiculoViewModel>(veiculo);

            return View(veiculoViewModel);
        }

        // GET: Veiculo/Create
        public ActionResult Create()
        {
            ViewData["Unidades"] = this.unidadeAdministrativaService.GetAllOrdemAlfabetica();
			ViewData["Frotas"] = this.frotaService.GetAllOrdemAlfabetica();
			ViewData["Modelos"] = this.modeloVeiculoService.GetAllOrdemAlfabetica();
			return View();
        }

        // POST: Veiculo/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(VeiculoViewModel veiculoViewModel)
        {
            if (ModelState.IsValid) {
                var veiculo = mapper.Map<Veiculo>(veiculoViewModel);
                veiculoService.Create(veiculo);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: Veiculo/Edit/5
        public ActionResult Edit(uint id)
        {
            var veiculo = veiculoService.Get(id);
            var veiculoViewModel = mapper.Map<VeiculoViewModel>(veiculo);
            return View(veiculoViewModel);
        }

        // POST: Veiculo/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, VeiculoViewModel veiculoViewModel)
        {
            if (ModelState.IsValid) {
                var veiculo = mapper.Map<Veiculo>(veiculoViewModel);
                veiculoService.Edit(veiculo);
            }

            return RedirectToAction(nameof(Index));
        }

        // GET: Veiculo/Delete/5
        public ActionResult Delete(uint id)
        {
            var veiculo = veiculoService.Get(id);
            var veiculoViewModel = mapper.Map<VeiculoViewModel>(veiculo);
            return View(veiculoViewModel);
        }

        // POST: Veiculo/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, VeiculoViewModel veiculoViewModel)
        {
            veiculoService.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}

