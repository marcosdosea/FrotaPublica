using AutoMapper;
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
        private readonly List<string> listaEstados;

        public UnidadeAdministrativaController(IUnidadeAdministrativaService unidadeAdministrativaService, IMapper mapper)
		{
			this.unidadeAdministrativaService = unidadeAdministrativaService;
			this.mapper = mapper;
            this.listaEstados = new List<string> { "AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO" };
        }

		// GET: UnidadeAdministrativa
		public ActionResult Index()
		{
            uint.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            if (idFrota == 0)
            {
                return Redirect("/Identity/Account/Login");
            }
            var unidades = unidadeAdministrativaService.GetAll(idFrota);
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
            ViewData["Estados"] = listaEstados;
            return View();
		}

		// POST: UnidadeAdministrativa/Create
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Create(UnidadeAdministrativaViewModel unidadeViewModel)
		{
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
            if (ModelState.IsValid)
			{
				try
				{
                    var unidade = mapper.Map<Unidadeadministrativa>(unidadeViewModel);
                    unidadeAdministrativaService.Create(unidade, idFrota);
                }
                catch (ServiceException exception)
                {
                    ViewData["Estados"] = listaEstados;
                    return View(unidadeViewModel);
                }
            }
			return RedirectToAction(nameof(Index));
		}

		// GET: UnidadeAdministrativa/Edit/5
		public ActionResult Edit(uint id)
		{
			var unidade = unidadeAdministrativaService.Get(id);
			var unidadeViewModel = mapper.Map<UnidadeAdministrativaViewModel>(unidade);
            ViewData["Estados"] = listaEstados;
            return View(unidadeViewModel);
		}

		// POST: UnidadeAdministrativa/Edit/5
		[HttpPost]
		[ValidateAntiForgeryToken]
		public ActionResult Edit(uint id, UnidadeAdministrativaViewModel unidadeViewModel)
		{
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
            if (ModelState.IsValid)
			{
				try
				{
                    var unidade = mapper.Map<Unidadeadministrativa>(unidadeViewModel);
                    unidadeAdministrativaService.Edit(unidade, idFrota);
                }
                catch (ServiceException exception)
                {
                    ViewData["Estados"] = listaEstados;
                    return View(unidadeViewModel);
                }
                
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
