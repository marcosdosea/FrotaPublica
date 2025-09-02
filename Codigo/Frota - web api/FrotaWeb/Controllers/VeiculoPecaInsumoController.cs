using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{
    [Authorize(Roles = "Administrador, Gestor")]
    public class VeiculoPecaInsumoController : Controller
    {
        private readonly IVeiculoPecaInsumoService veiculoPecaInsumoService;
        private readonly IMapper mapper;
        private readonly IVeiculoService veiculoService;
        private readonly IPecaInsumoService pecaInsumoService;


        public VeiculoPecaInsumoController(IVeiculoPecaInsumoService service, IMapper mapper, IVeiculoService veiculoService, IPecaInsumoService pecaInsumoService)
        {
            this.veiculoPecaInsumoService = service;
            this.mapper = mapper;
            this.veiculoService = veiculoService;
            this.pecaInsumoService = pecaInsumoService;
        }

        // GET: VeiculoPecaInsumoController
        public ActionResult Index()
        {
            var veiculoPecaInsumos = veiculoPecaInsumoService.GetAll();
            var veiculoPecaInsumosViewModel = mapper.Map<List<VeiculoPecaInsumoViewModel>>(veiculoPecaInsumos);
            return View(veiculoPecaInsumosViewModel);
        }

        // GET: VeiculoPecaInsumoController/Details/5
        public ActionResult Details(uint IdVeiculo, uint IdPecaInsumo)
        {
            var veiculoPecaInsumo = veiculoPecaInsumoService.Get(IdVeiculo, IdPecaInsumo);
            var veiculoPecaInsumoViewModel = mapper.Map<VeiculoPecaInsumoViewModel>(veiculoPecaInsumo);
            return View(veiculoPecaInsumoViewModel);
        }

        // GET: VeiculoPecaInsumoController/Create
        public ActionResult Create()
        {
            uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            if (idFrota == 0)
            {
                return Redirect("/Identity/Account/Login");
            }
            ViewData["Veiculos"] = this.veiculoService.GetVeiculoDTO((int)idFrota);
            ViewData["PecaInsumos"] = this.pecaInsumoService.GetAll(idFrota);
            return View();
        }

        // POST: VeiculoPecaInsumoController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(VeiculoPecaInsumoViewModel veiculoPecaInsumoModel)
        {
            if (ModelState.IsValid)
            {
                var veiculoPecaInsumo = mapper.Map<Veiculopecainsumo>(veiculoPecaInsumoModel);
                veiculoPecaInsumoService.Create(veiculoPecaInsumo);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: VeiculoPecaInsumoController/Edit/5
        public ActionResult Edit(uint IdVeiculo, uint IdPecaInsumo)
        {
            var veiculoPecaInsumo = veiculoPecaInsumoService.Get(IdVeiculo, IdPecaInsumo);
            var veiculoPecaInsumoViewModel = mapper.Map<VeiculoPecaInsumoViewModel>(veiculoPecaInsumo);
            return View(veiculoPecaInsumoViewModel);
        }

        // POST: VeiculoPecaInsumoController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint IdVeiculo, uint IdPecaInsumo, VeiculoPecaInsumoViewModel model)
        {
            if (ModelState.IsValid)
            {
                var veiculoPecaInsumo = mapper.Map<Veiculopecainsumo>(model);
                veiculoPecaInsumoService.Edit(veiculoPecaInsumo);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: VeiculoPecaInsumoController/Delete/5
        public ActionResult Delete(uint IdVeiculo, uint IdPecaInsumo)
        {
            var veiculo = veiculoPecaInsumoService.Get(IdVeiculo, IdPecaInsumo);
            var veiculoViewModel = mapper.Map<VeiculoPecaInsumoViewModel>(veiculo);
            return View(veiculoViewModel);
        }

        // POST: VeiculoPecaInsumoController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint IdVeiculo, uint IdPecaInsumo, VeiculoPecaInsumoViewModel veiculoPecaInsumoModel)
        {
            var veiculoPecaInsumo = mapper.Map<Veiculopecainsumo>(veiculoPecaInsumoModel);
            veiculoPecaInsumoService.Delete(veiculoPecaInsumo);
            return RedirectToAction(nameof(Index));
        }
    }
}
