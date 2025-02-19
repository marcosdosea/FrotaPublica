using System;
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
        [Route("Veiculo/Index/{page}")]
        [Route("Veiculo/{page}")]
        [Route("Veiculo")]
        public ActionResult Index([FromRoute] int page = 0)
        {
            uint.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);

            int length = 15;
            var listaVeiculos = veiculoService.GetPaged(page, length, idFrota).ToList();

            var totalVeiculos = veiculoService.GetAll(idFrota).Count();
            var totalPages = (int)Math.Ceiling((double)totalVeiculos / length);

            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = totalPages;
            var veiculosViewModel = mapper.Map<List<VeiculoViewModel>>(listaVeiculos);
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
        [Route("Veiculo/Create")]
        public ActionResult Create()
        {
            uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            ViewData["Unidades"] = this.unidadeAdministrativaService.GetAllOrdemAlfabetica(idFrota);
            ViewData["Modelos"] = this.modeloVeiculoService.GetAllOrdemAlfabetica(idFrota);
            return View();
        }

        // POST: Veiculo/Create
        [HttpPost]
        [Route("Veiculo/Create")]
        [ValidateAntiForgeryToken]
        public ActionResult Create(VeiculoViewModel veiculoViewModel)
        {
            if (ModelState.IsValid)
            {
                uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
                var veiculo = mapper.Map<Veiculo>(veiculoViewModel);
                veiculo.IdFrota = idFrota;
                TempData["MensagemSucesso"] = "Veículo cadastrado com sucesso!";
                try
                {
                    veiculoService.Create(veiculo);
                }
                catch (ServiceException exception)
                {
                    ModelState.AddModelError(exception.AtributoError!, "Este dado já está cadastrado");
                    ViewData["Unidades"] = this.unidadeAdministrativaService.GetAllOrdemAlfabetica(idFrota);
                    ViewData["Modelos"] = this.modeloVeiculoService.GetAllOrdemAlfabetica(idFrota);
                    return View(veiculoViewModel);
                }

            }
            return RedirectToAction(nameof(Index));
        }

        // GET: Veiculo/Edit/5
        public ActionResult Edit(uint id)
        {
            var veiculo = veiculoService.Get(id);
            var veiculoViewModel = mapper.Map<VeiculoViewModel>(veiculo);
            ViewData["Unidades"] = this.unidadeAdministrativaService.GetAllOrdemAlfabetica(veiculoViewModel.IdFrota);
            ViewData["Modelos"] = this.modeloVeiculoService.GetAllOrdemAlfabetica(veiculoViewModel.IdFrota);
            return View(veiculoViewModel);
        }

        // POST: Veiculo/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, VeiculoViewModel veiculoViewModel)
        {
            if (ModelState.IsValid)
            {
                uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
                veiculoViewModel.IdFrota = idFrota;
                var veiculo = mapper.Map<Veiculo>(veiculoViewModel);
                try
                {
                    veiculoService.Edit(veiculo);
                }
                catch (ServiceException exception)
                {
                    ModelState.AddModelError(exception.AtributoError!, "Este dado já está cadastrado");
                    ViewData["Unidades"] = this.unidadeAdministrativaService.GetAllOrdemAlfabetica(veiculo.IdFrota);
                    ViewData["Modelos"] = this.modeloVeiculoService.GetAllOrdemAlfabetica(veiculo.IdFrota);
                    return View(veiculoViewModel);
                }
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
            try
            {
                veiculoService.Delete(id);
                TempData["MensagemSucesso"] = "Veículo removido com sucesso!";
            }
            catch (ServiceException exception)
            {
                TempData["MensagemError"] = exception.MensagemCustom;
            }
            return RedirectToAction(nameof(Index));
        }
    }
}

