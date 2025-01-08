using AutoMapper;
using Core;
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
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
            if (idFrota == 0)
            {
                return Redirect("/Identity/Account/Login");
            }
            var listaAbastecimentos = abastecimentoService.GetAll(idFrota);
            var listaAbastecimentosViewModel = mapper.Map<List<AbastecimentoViewModel>>(listaAbastecimentos);
            return View(listaAbastecimentosViewModel);
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
        public ActionResult Create(AbastecimentoViewModel abastecimentoViewModel)
        {
            if (ModelState.IsValid)
            {
                int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
                if (idFrota == 0)
                {
                    return Redirect("/Identity/Account/Login");
                }
                var abastecimento = mapper.Map<Abastecimento>(abastecimentoViewModel);
                abastecimentoService.Create(abastecimento, idFrota);
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
        public ActionResult Edit(uint id, AbastecimentoViewModel abastecimentoViewModel)
        {
            if (ModelState.IsValid)
            {
                int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
                if (idFrota == 0)
                {
                    return Redirect("/Identity/Account/Login");
                }
                var abastecimento = mapper.Map<Abastecimento>(abastecimentoViewModel);
                abastecimentoService.Edit(abastecimento, idFrota);
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
        public ActionResult Delete(uint id, AbastecimentoViewModel abastecimentoViewModel)
        {
            abastecimentoService.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
