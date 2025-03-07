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
        private readonly List<string> listaEstados;

        public FornecedorController(IFornecedorService fornecedorService, IMapper mapper)
        {
            this.fornecedorService = fornecedorService;
            this.mapper = mapper;
            this.listaEstados = new List<string> { "AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO" };
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
            ViewData["Estados"] = listaEstados;
            return View();
        }

        // POST: FornecedorController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(FornecedorViewModel fornecedorViewModel)
        {
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
            if (ModelState.IsValid)
            {
                try
                {
                    var fornecedor = mapper.Map<Fornecedor>(fornecedorViewModel);
                    fornecedorService.Create(fornecedor, idFrota);
                }
                catch (ServiceException exception)
                {
                    ViewData["Estados"] = listaEstados;
                    return View(fornecedorViewModel);
                }
                
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: FornecedorController/Edit/5
        public ActionResult Edit(uint id)
        {
            var fornecedor = fornecedorService.Get(id);
            var fornecedorModel = mapper.Map<FornecedorViewModel>(fornecedor);
            ViewData["Estados"] = listaEstados;
            return View(fornecedorModel);
        }

        // POST: FornecedorController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, FornecedorViewModel fornecedorViewModel)
        {
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
            if (ModelState.IsValid)
            {
                try
                {
                    var fornecedor = mapper.Map<Fornecedor>(fornecedorViewModel);
                    fornecedorService.Edit(fornecedor, idFrota);
                }
                catch (ServiceException exception)
                {
                    ViewData["Estados"] = listaEstados;
                    return View(fornecedorViewModel);
                }
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