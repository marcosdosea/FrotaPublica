using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{
    [Authorize]
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
            var listaFornecedor = fornecedorService.GetAll();
            var listaFornecedorModel = mapper.Map<List<FornecedorViewModel>>(listaFornecedor);
            return View(listaFornecedorModel);
        }

        // GET: FornecedorController/Details/5
        public ActionResult Details(uint id)
        {
            Fornecedor fornecedor = fornecedorService.Get(id);
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
            try
            {
                if (ModelState.IsValid)
                {
                    var fornecedor = mapper.Map<Fornecedor>(fornecedorViewModel);
                    fornecedorService.Create(fornecedor);
                }
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
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
        public ActionResult Edit(int id, FornecedorViewModel fornecedorViewModel)
        {
            try
            {
                if(ModelState.IsValid)
                {
                    var fornecedor = mapper.Map<Fornecedor>(fornecedorViewModel);
                    fornecedorService.Edit(fornecedor);
                }
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }

        // GET: FornecedorController/Delete/5
        public ActionResult Delete(int id)
        {
            Fornecedor fornecedor = fornecedorService.Get((uint)id);
            var fornecedorModel = mapper.Map<FornecedorViewModel>(fornecedor);
            return View(fornecedorModel);
        }

        // POST: FornecedorController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, FornecedorViewModel fornecedorViewModel)
        {
            try
            {
                fornecedorService.Delete(id);
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }
    }
}