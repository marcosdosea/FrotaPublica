using AutoMapper;
using Core;
using Core.Datatables;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Service;

namespace FrotaWeb.Controllers
{

    [Authorize(Roles = "Gestor, Motorista")]
    public class AbastecimentoController : Controller
    {
        private readonly IAbastecimentoService abastecimentoService;
        private readonly IMapper mapper;

        public AbastecimentoController(IAbastecimentoService abastecimentoService, IMapper mapper)
        {
            this.mapper = mapper;
            this.abastecimentoService = abastecimentoService;
        }
        // GET: AbastecimentoController
        public ActionResult Index([FromRoute] int page = 0)
        {
            var listaAbastecimentos = abastecimentoService.GetAll();
            var listaAbastecimentosViewModel = mapper.Map<List<AbastecimentoViewModel>>(listaAbastecimentos);
            return View(listaAbastecimentosViewModel);
        }

        [HttpPost]
        public IActionResult GetDataPage(DatatableRequest request)
        {
            var response = abastecimentoService.GetDataPage(request);
            return Json(response);
        }

        // GET: AbastecimentoController/Details/5
        public ActionResult Details(uint id)
        {
            var abastecimento = abastecimentoService.Get(id);
            var abastecimentoView = mapper.Map<AbastecimentoViewModel>(abastecimento);
            return View(abastecimentoView);
        }

        // GET: AbastecimentoController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: AbastecimentoController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(AbastecimentoViewModel abastecimento)
        {
            if (ModelState.IsValid)
            {
                var _abastecimento = mapper.Map<Abastecimento>(abastecimento);
                abastecimentoService.Create(_abastecimento);
            }

            return RedirectToAction(nameof(Index));
        }

        // GET: AbastecimentoController/Edit/5
        public ActionResult Edit(uint id)
        {
            var abastecimento = abastecimentoService.Get(id);
            var abastecimentoView = mapper.Map<AbastecimentoViewModel>(abastecimento);
            return View(abastecimentoView);
        }

        // POST: AbastecimentoController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, AbastecimentoViewModel abastecimento)
        {
            if (ModelState.IsValid)
            {
                var _abastecimento = mapper.Map<Abastecimento>(abastecimento);
                abastecimentoService.Edit(_abastecimento);
            }

            return RedirectToAction(nameof(Index));
        }

        // GET: AbastecimentoController/Delete/5
        public ActionResult Delete(uint id)
        {
            var abastecimento = abastecimentoService.Get(id);
            var abastecimentoViewModel = mapper.Map<AbastecimentoViewModel>(abastecimento);
            return View(abastecimentoViewModel);
        }

        // POST: AbastecimentoController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, AbastecimentoViewModel abastecimento)
        {
            abastecimentoService.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
