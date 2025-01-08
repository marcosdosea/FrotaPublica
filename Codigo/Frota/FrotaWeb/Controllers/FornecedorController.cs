using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{
    [Authorize(Roles = "Gestor")]
    public class FornecedorController : Controller
    {

        private readonly IFornecedorService fornecedorService;
        private readonly IMapper mapper;

        public FornecedorController(IFornecedorService fornecedorService, IMapper mapper)
        {
            this.fornecedorService = fornecedorService;
            this.mapper = mapper;
        }

        // GET: FornecedorController
        public ActionResult Index()
        {
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
            if (idFrota == 0)
            {
                return Redirect("/Identity/Account/Login");
            }

            var listaFornecedor = fornecedorService.GetAll(idFrota);
            var listaFornecedorModel = mapper.Map<List<FornecedorViewModel>>(listaFornecedor);
            return View(listaFornecedorModel);
        }

        // GET: FornecedorController/Details/5
        public ActionResult Details(uint id)
        {
            Fornecedor? fornecedor = fornecedorService.Get(id);
            var fornecedorModel = mapper.Map<FornecedorViewModel>(fornecedor);
            return View(fornecedorModel);
        }

        // GET: FornecedorController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: FornecedorController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(FornecedorViewModel fornecedorViewModel)
        {
            if (ModelState.IsValid)
            {

                int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
                if (idFrota == 0)
                {
                    return Redirect("/Identity/Account/Login");
                }
                var fornecedor = mapper.Map<Fornecedor>(fornecedorViewModel);
                fornecedorService.Create(fornecedor, idFrota);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: FornecedorController/Edit/5
        public ActionResult Edit(uint id)
        {
            var fornecedor = fornecedorService.Get(id);
            var fornecedorModel = mapper.Map<FornecedorViewModel>(fornecedor);
            return View(fornecedorModel);
        }

        // POST: FornecedorController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, FornecedorViewModel fornecedorViewModel)
        {
            if (ModelState.IsValid)
            {
                int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
                if (idFrota == 0)
                {
                    return Redirect("/Identity/Account/Login");
                }
                var fornecedor = mapper.Map<Fornecedor>(fornecedorViewModel);
                fornecedorService.Edit(fornecedor, idFrota);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: FornecedorController/Delete/5
        public ActionResult Delete(uint id)
        {
            Fornecedor? fornecedor = fornecedorService.Get((uint)id);
            var fornecedorModel = mapper.Map<FornecedorViewModel>(fornecedor);
            return View(fornecedorModel);
        }

        // POST: FornecedorController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, FornecedorViewModel fornecedorViewModel)
        {
            fornecedorService.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}