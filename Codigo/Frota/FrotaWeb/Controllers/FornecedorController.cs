using AutoMapper;
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
        public ActionResult Details(int id)
        {
            return View();
        }

        // GET: FornecedorController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: FornecedorController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }

        // GET: FornecedorController/Edit/5
        public ActionResult Edit(int id)
        {
            return View();
        }

        // POST: FornecedorController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int id, IFormCollection collection)
        {
            try
            {
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
            return View();
        }

        // POST: FornecedorController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id, IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }
    }
}