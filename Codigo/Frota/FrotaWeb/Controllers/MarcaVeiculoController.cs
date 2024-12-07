using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{
    [Authorize(Roles = "Administrador")]
    public class MarcaVeiculoController : Controller
	{
		private readonly IMarcaVeiculoService _service;
		private readonly IMapper mapper;

		public MarcaVeiculoController(IMarcaVeiculoService service, IMapper mapper)
		{
			this._service = service;
			this.mapper = mapper;
		}

		// GET: MarcaVeiculo
		public ActionResult Index()
		{
			var marcaVeiculos = _service.GetAll();
			var marcaVeiculosViewModel = mapper.Map<List<MarcaVeiculoViewModel>>(marcaVeiculos);
			return View(marcaVeiculosViewModel);
		}

		// GET: MarcaVeiculo/Details/5
		public ActionResult Details(uint id)
		{
			var marcaVeiculo = _service.Get(id);
			var marcaVeiculosViewModel = mapper.Map<MarcaVeiculoViewModel>(marcaVeiculo);

			return View(marcaVeiculosViewModel);
		}

		// GET: MarcaVeiculo/Create
		public ActionResult Create()
		{
			return View();
		}

		// POST: MarcaVeiculo/Create
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Create(MarcaVeiculoViewModel marcaVeiculoViewModel)
		{
			if (ModelState.IsValid)
			{
				var marcaVeiculo = mapper.Map<Marcaveiculo>(marcaVeiculoViewModel);
				_service.Create(marcaVeiculo);
			}

			return RedirectToAction(nameof(Index));
		}

		// GET: MarcaVeiculo/Edit/5
		public ActionResult Edit(uint id)
		{
			var marcaVeiculo = _service.Get(id);
			var marcaVeiculoViewModel = mapper.Map<MarcaVeiculoViewModel>(marcaVeiculo);

			return View(marcaVeiculoViewModel);
		}

		// POST: MarcaVeiculo/Edit/5
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Edit(uint id, MarcaVeiculoViewModel marcaVeiculoViewModel)
		{
			if (ModelState.IsValid)
			{
				var marcaVeiculo = mapper.Map<Marcaveiculo>(marcaVeiculoViewModel);
				_service.Edit(marcaVeiculo);
			}

			return RedirectToAction(nameof(Index));
		}

		// GET: MarcaVeiculo/Delete/5
		public ActionResult Delete(uint id)
		{
			var marcaVeiculo = _service.Get(id);
			var marcaVeiculoViewModel = mapper.Map<MarcaVeiculoViewModel>(marcaVeiculo);
			return View(marcaVeiculoViewModel);
		}

		// POST: MarcaVeiculo/Delete/5
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Delete(uint id, MarcaVeiculoViewModel marcaVeiculo)
		{
			_service.Delete(id);
			return RedirectToAction(nameof(Index));
		}
	}
}

