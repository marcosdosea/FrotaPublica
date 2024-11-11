using AutoMapper;
using Core;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Service;

namespace FrotaWeb.Controllers
{
    [Authorize]
    public class ManutencaoController : Controller
    {
        private readonly IManutencaoService manutencaoService;
        private readonly IMapper mapper;

        public ManutencaoController(IManutencaoService manutencaoService, IMapper mapper)
        {
            this.manutencaoService = manutencaoService;
            this.mapper = mapper;
        }

        // GET: ManutencaoController
        public ActionResult Index()
        {
            var listaManutencao = manutencaoService.GetAll();
            var listaManutencaoViewModel = mapper.Map<List<ManutencaoViewModel>>(listaManutencao);
            return View(listaManutencaoViewModel);
        }

        // GET: ManutencaoController/Details/5
        public ActionResult Details(uint id)
        {
            var manutencao = manutencaoService.Get(id);
            var manutencaoViewModel = mapper.Map<ManutencaoViewModel>(manutencao);
            return View(manutencaoViewModel);
        }

        // GET: ManutencaoController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: ManutencaoController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(ManutencaoViewModel manutencaoViewModel)
        {
            if (ModelState.IsValid)
            {
                var manutencao = mapper.Map<Manutencao>(manutencaoViewModel);
                manutencaoService.Create(manutencao);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: ManutencaoController/Edit/5
        public ActionResult Edit(uint id)
        {
            var manutencao = manutencaoService.Get(id);
            var manutencaoViewModel = mapper.Map<ManutencaoViewModel>(manutencao);
            return View(manutencaoViewModel);
        }

        // POST: ManutencaoController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, ManutencaoViewModel manutencaoViewModel)
        {
            if (ModelState.IsValid)
            {
                var manutencao = mapper.Map<Manutencao>(manutencaoViewModel);
                manutencaoService.Edit(manutencao);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: ManutencaoController/Delete/5
        public ActionResult Delete(uint id)
        {
            var manutencao = manutencaoService.Get(id);
            var manutencaoViewModel = mapper.Map<ManutencaoViewModel>(manutencao);
            return View(manutencaoViewModel);
        }

        // POST: ManutencaoController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, ManutencaoViewModel manutencaoViewModel)
        {
            manutencaoService.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
