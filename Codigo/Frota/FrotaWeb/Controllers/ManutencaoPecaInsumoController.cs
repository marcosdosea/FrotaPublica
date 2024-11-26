using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{
	[Authorize]
	public class ManutencaoPecaInsumoController : Controller
	{
		private readonly IManutencaoPecaInsumoService manutencaoPecaInsumoService;
		private readonly IMapper mapper;

		public ManutencaoPecaInsumoController(IManutencaoPecaInsumoService manutencaoPecaInsumoService, IMapper mapper)
		{
			this.manutencaoPecaInsumoService = manutencaoPecaInsumoService;
			this.mapper = mapper;
		}

		// GET: ManutencaoPecaInsumoController
		public ActionResult Index()
		{
			var manutencoesPecaInsumo = manutencaoPecaInsumoService.GetAll();
			var manutencoesPecaInsumoViewModel = mapper.Map<List<ManutencaoPecaInsumoViewModel>>(manutencoesPecaInsumo);
			return View(manutencoesPecaInsumoViewModel);
		}

		// GET: ManutencaoPecaInsumoController/Details/5/6
		public ActionResult Details(uint idManutencao, uint idPecaInsumo)
		{
			var manutencaoPecaInsumo = manutencaoPecaInsumoService.Get(idManutencao, idPecaInsumo);
			if(manutencaoPecaInsumo == null)
			{
				return NotFound();
			}
			var manutencaoPecaInsumoViewModel = mapper.Map<ManutencaoPecaInsumoViewModel>(manutencaoPecaInsumo);
			return View(manutencaoPecaInsumoViewModel);
		}

		// GET: ManutencaoPecaInsumoController/Create
		public ActionResult Create()
		{
			return View();
		}

		// POST: ManutencaoPecaInsumoController/Create
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Create(ManutencaoPecaInsumoViewModel manutencaoPecaInsumoViewModel)
		{
			if (ModelState.IsValid)
			{
				var manutencaoPecaInsumo = mapper.Map<Manutencaopecainsumo>(manutencaoPecaInsumoViewModel);
				manutencaoPecaInsumoService.Create(manutencaoPecaInsumo);
			}
			return RedirectToAction(nameof(Index));
		}

		// GET: ManutencaoPecaInsumoController/Edit/5/6
		public ActionResult Edit(uint idManutencao, uint idPecaInsumo)
		{
			var manutencaoPecaInsumo = manutencaoPecaInsumoService.Get(idManutencao, idPecaInsumo);
			var manutencaoPecaInsumoViewModel = mapper.Map<ManutencaoPecaInsumoViewModel>(manutencaoPecaInsumo);
			return View(manutencaoPecaInsumoViewModel);
		}

		// POST: ManutencaoPecaInsumoController/Edit/5
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Edit(uint idManutencao, ManutencaoPecaInsumoViewModel manutencaoPecaInsumoViewModel)
		{
			if (ModelState.IsValid)
			{
				var manutencaoPecaInsumo = mapper.Map<Manutencaopecainsumo>(manutencaoPecaInsumoViewModel);
				manutencaoPecaInsumoService.Edit(manutencaoPecaInsumo);
			}
			return RedirectToAction(nameof(Index));
		}

		// GET: ManutencaoPecaInsumoController/Delete/5/6
		public ActionResult Delete(uint idManutencao, uint idPecaInsumo)
		{
			var manutencaoPecaInsumo = manutencaoPecaInsumoService.Get(idManutencao, idPecaInsumo);
			var manutencaoPecaInsumoViewModel = mapper.Map<ManutencaoPecaInsumoViewModel>(manutencaoPecaInsumo);
			return View(manutencaoPecaInsumoViewModel);
		}

		// POST: ManutencaoPecaInsumoController/Delete/5
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Delete(uint idManutencao, ManutencaoPecaInsumoViewModel manutencaoPecaInsumoViewModel)
		{
			manutencaoPecaInsumoService.Delete(idManutencao, manutencaoPecaInsumoViewModel.IdPecaInsumo);
			return RedirectToAction(nameof(Index));
		}
	}
}
