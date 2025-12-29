using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{
    [Authorize(Roles = "Gestor, Motorista")]
    public class VistoriaController : Controller
	{
		private readonly IVistoriaService vistoriaService;
		private readonly IMapper mapper;

		public VistoriaController(IVistoriaService vistoriaService, IMapper mapper)
		{
			this.vistoriaService = vistoriaService;
			this.mapper = mapper;
		}

		// GET: Vistoria
		[Route("Vistoria/Index/{page}")]
		[Route("Vistoria/{page}")]
		[Route("Vistoria")]
		public ActionResult Index([FromRoute] int page = 0)
		{
            uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            
            int itemsPerPage = 20;
            var allVistorias = vistoriaService.GetAll(idFrota).ToList();
            var totalItems = allVistorias.Count;
            
            var pagedItems = allVistorias
                .Skip(page * itemsPerPage)
                .Take(itemsPerPage)
                .ToList();
            
            var pagedResult = new PagedResult<VistoriaViewModel>
            {
                Items = mapper.Map<List<VistoriaViewModel>>(pagedItems),
                CurrentPage = page,
                ItemsPerPage = itemsPerPage,
                TotalItems = totalItems,
                TotalPages = (int)Math.Ceiling((double)totalItems / itemsPerPage)
            };

            ViewBag.PagedResult = pagedResult;
			return View(pagedResult.Items);
		}

		// GET: Vistoria/Details/5
		public ActionResult Details(int id)
		{
			var vistoria = vistoriaService.Get(id);
			var vistoriaViewModel = mapper.Map<VistoriaViewModel>(vistoria);
			return View(vistoriaViewModel);
		}

		// GET: Vistoria/Create
		public ActionResult Create()
		{
			return View();
		}

		// POST: Vistoria/Create
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Create(VistoriaViewModel vistoriaViewModel)
		{
			if (ModelState.IsValid)
			{
				var vistoria = mapper.Map<Vistorium>(vistoriaViewModel);
				vistoriaService.Create(vistoria);
			}

			return RedirectToAction(nameof(Index));
		}

		// GET: Vistoria/Edit/5
		public ActionResult Edit(int id)
		{
			var vistoria = vistoriaService.Get(id);
			var vistoriaViewModel = mapper.Map<VistoriaViewModel>(vistoria);

			return View(vistoriaViewModel);
		}

		// POST: Vistoria/Edit/5
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Edit(uint id, VistoriaViewModel vistoriaViewModel)
		{
			if (ModelState.IsValid)
			{
				var vistoria = mapper.Map<Vistorium>(vistoriaViewModel);
				vistoriaService.Edit(vistoria);
			}

			return RedirectToAction(nameof(Index));
		}

		// GET: Vistoria/Delete/5
		public ActionResult Delete(int id)
		{
			var vistoria = vistoriaService.Get(id);
			var vistoriaViewModel = mapper.Map<VistoriaViewModel>(vistoria);
			return View(vistoriaViewModel);
		}

		// POST: Vistoria/Delete/5
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Delete(int id, VistoriaViewModel vistoriaViewModel)
		{
			TempData["MensagemConfirmacao"] = "Tem certeza que deseja excluir esta vistoria?";
			vistoriaService.Delete(id);
			return RedirectToAction(nameof(Index));
		}
	}
}
