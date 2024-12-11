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
            var listaFornecedor = fornecedorService.GetAll();
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
                var fornecedor = mapper.Map<Fornecedor>(fornecedorViewModel);
                fornecedorService.Create(fornecedor);
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
                var fornecedor = mapper.Map<Fornecedor>(fornecedorViewModel);
                fornecedorService.Edit(fornecedor);
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

        [HttpGet]
        public async Task<IActionResult> ConsultaCnpj(string cnpj)
        {
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Add("User-Agent", "Mozilla/5.0");
                var response = await client.GetAsync($"https://www.receitaws.com.br/v1/cnpj/{cnpj}");
                if (response.IsSuccessStatusCode)
                {
                    var content = await response.Content.ReadAsStringAsync();
                    return Content(content, "application/json");
                }
                else
                {
                    return BadRequest("Erro ao consultar CNPJ.");
                }
            }
        }
    }
}