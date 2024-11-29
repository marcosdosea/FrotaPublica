using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{
    [Authorize(Roles = "GESTOR, MOTORISTA")]
    public class PercursoController : Controller
	{
		private readonly IPercursoService percursoService;
		private readonly IMapper mapper;
		public PercursoController(IPercursoService percursoService, IMapper mapper)
		{
			this.percursoService = percursoService;
			this.mapper = mapper;
		}
		// GET: PercursoController
		public ActionResult Index()
		{
			var listaPercurso = percursoService.GetAll();
			var listaPercursoModel = mapper.Map<List<PercursoViewModel>>(listaPercurso);
			return View(listaPercursoModel);
		}

		// GET: PercursoController/Details/5
		public ActionResult Details(uint id)
		{
			Percurso percurso = percursoService.Get(id);
			PercursoViewModel percursoModel = mapper.Map<PercursoViewModel>(percurso);
			return View(percursoModel);
		}

		// GET: PercursoController/Create
		public ActionResult Create()
		{
			return View();
		}

		// POST: PercursoController/Create
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Create(PercursoViewModel percursoViewModel)
		{
			if(ModelState.IsValid)
			{
				var percurso = mapper.Map<Percurso>(percursoViewModel);
				percursoService.Create(percurso);
			}
			return RedirectToAction(nameof(Index));
		}

		// GET: PercursoController/Edit/5
		public ActionResult Edit(uint id)
		{
			Percurso percurso = percursoService.Get(id);
			PercursoViewModel percursoModel = mapper.Map<PercursoViewModel>(percurso);
			return View(percursoModel);
		}

		// POST: PercursoController/Edit/5
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Edit(uint id, PercursoViewModel percursoViewModel)
		{
			if (ModelState.IsValid)
			{
				var percurso = mapper.Map<Percurso>(percursoViewModel);
				percursoService.Edit(percurso);
			}
			return RedirectToAction(nameof(Index));
		}

		// GET: PercursoController/Delete/5
		public ActionResult Delete(uint id)
		{
			Percurso percurso = percursoService.Get(id);
			PercursoViewModel percursoModel = mapper.Map<PercursoViewModel>(percurso);
			return View(percursoModel);
		}

		// POST: PercursoController/Delete/5
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Delete(uint id, PercursoViewModel percursoViewModel)
		{
			percursoService.Delete(id);
			return RedirectToAction(nameof(Index));
		}
	}
}
