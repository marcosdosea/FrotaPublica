using AutoMapper;
using Core;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Service;

namespace FrotaWeb.Controllers
{

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
            var listaManutencaoModel = mapper.Map<List<ManutencaoViewModel>>(listaManutencao);
            return View(listaManutencaoModel);
        }

        // GET: ManutencaoController/Details/5
        public ActionResult Details(uint id)
        {
            var manutencao = manutencaoService.Get(id);
            var manutencaoModel = mapper.Map<ManutencaoViewModel>(manutencao);
            return View(manutencaoModel);
        }

        // GET: ManutencaoController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: ManutencaoController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(ManutencaoViewModel manutencaoModel)
        {
            if (ModelState.IsValid)
            {
                var manutencao = mapper.Map<Manutencao>(manutencaoModel);
                manutencaoService.Create(manutencao);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: ManutencaoController/Edit/5
        public ActionResult Edit(uint id)
        {
            var manutencao = manutencaoService.Get(id);
            var manutencaoModel = mapper.Map<ManutencaoViewModel>(manutencao);
            return View(manutencaoModel);
        }

        // POST: ManutencaoController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, ManutencaoViewModel manutencaoModel)
        {
            if (ModelState.IsValid)
            {
                var manutencao = mapper.Map<Manutencao>(manutencaoModel);
                manutencaoService.Edit(manutencao);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: ManutencaoController/Delete/5
        public ActionResult Delete(uint id)
        {
            var manutencao = manutencaoService.Get(id);
            var manutencaoModel = mapper.Map<ManutencaoViewModel>(manutencao);
            return View(manutencaoModel);
        }

        // POST: ManutencaoController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, ManutencaoViewModel manutencaoModel)
        {
            manutencaoService.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
