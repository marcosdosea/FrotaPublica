﻿using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;


namespace FrotaWeb.Controllers
{
    [Authorize(Roles = "Gestor")]
    public class UnidadeAdministrativaController : Controller
	{
		private readonly IUnidadeAdministrativaService unidadeAdministrativaService;
		private readonly IMapper mapper;

		public UnidadeAdministrativaController(IUnidadeAdministrativaService unidadeAdministrativaService, IMapper mapper)
		{
			this.unidadeAdministrativaService = unidadeAdministrativaService;
			this.mapper = mapper;
		}

		// GET: UnidadeAdministrativa
		public ActionResult Index()
		{
			var unidades = unidadeAdministrativaService.GetAll();
			var unidadesViewModel = mapper.Map<List<UnidadeAdministrativaViewModel>>(unidades);
			return View(unidadesViewModel);
		}

		// GET: UnidadeAdministrativa/Details/5
		public ActionResult Details(uint id)
		{
			var unidades = unidadeAdministrativaService.Get(id);
			var unidadesViewModel = mapper.Map<UnidadeAdministrativaViewModel>(unidades);
			return View(unidadesViewModel);
		}

		// GET: UnidadeAdministrativa/Create
		public ActionResult Create()
		{
			return View();
		}

		// POST: UnidadeAdministrativa/Create
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Create(UnidadeAdministrativaViewModel unidadeViewModel)
		{
			if (ModelState.IsValid)
			{
				var unidade = mapper.Map<Unidadeadministrativa>(unidadeViewModel);
				unidadeAdministrativaService.Create(unidade);
			}

			return RedirectToAction(nameof(Index));
		}

		// GET: UnidadeAdministrativa/Edit/5
		public ActionResult Edit(uint id)
		{
			var unidade = unidadeAdministrativaService.Get(id);
			var unidadeViewModel = mapper.Map<UnidadeAdministrativaViewModel>(unidade);
			return View(unidadeViewModel);
		}

		// POST: UnidadeAdministrativa/Edit/5
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Edit(uint id, UnidadeAdministrativaViewModel unidadeViewModel)
		{
			if (ModelState.IsValid)
			{
				var unidade = mapper.Map<Unidadeadministrativa>(unidadeViewModel);
				unidadeAdministrativaService.Edit(unidade);
			}

			return RedirectToAction(nameof(Index));
		}

		// GET: UnidadeAdministrativa/Delete/5
		public ActionResult Delete(uint id)
		{
			var unidade = unidadeAdministrativaService.Get(id);
			var unidadeViewModel = mapper.Map<UnidadeAdministrativaViewModel>(unidade);
			return View(unidadeViewModel);
		}

		// POST: UnidadeAdministrativa/Delete/5
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Delete(uint id, UnidadeAdministrativaViewModel unidadeViewModel)
		{
			unidadeAdministrativaService.Delete(id);
			return RedirectToAction(nameof(Index));
		}
	}
}

