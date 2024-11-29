using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;


namespace FrotaWeb.Controllers
{

    [Authorize(Roles = "GESTOR")]
    public class PessoaController : Controller
    {
        private readonly IPessoaService pessoaService;
        private readonly IMapper mapper;

        public PessoaController(IPessoaService pessoaService, IMapper mapper)
        {
            this.pessoaService = pessoaService;
            this.mapper = mapper;
        }

        // GET: PessoaController
        public ActionResult Index()
        {
            var listaPessoas = pessoaService.GetAll();
            var listaPessoasModel = mapper.Map<List<PessoaViewModel>>(listaPessoas);
            return View(listaPessoasModel);
        }

        // GET: PessoaController/Details/5
        public ActionResult Details(uint id)
        {
            Pessoa pessoa = pessoaService.Get(id);
            PessoaViewModel pessoaModel = mapper.Map<PessoaViewModel>(pessoa);
            return View(pessoaModel);
        }

        // GET: PessoaController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: PessoaController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(PessoaViewModel pessoaModel)
        {
            if (ModelState.IsValid)
            {
                var pessoa = mapper.Map<Pessoa>(pessoaModel);
                pessoaService.Create(pessoa);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: PessoaController/Edit/5
        public ActionResult Edit(uint id)
        {
            Pessoa pessoa = pessoaService.Get(id);
            PessoaViewModel pessoaModel = mapper.Map<PessoaViewModel>(pessoa);
            return View(pessoaModel);
        }

        // POST: PessoaController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, PessoaViewModel pessoaModel)
        {
            if (ModelState.IsValid)
            {
                var pessoa = mapper.Map<Pessoa>(pessoaModel);
                pessoaService.Edit(pessoa);
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: PessoaController/Delete/5
        public ActionResult Delete(uint id)
        {
            Pessoa pessoa = pessoaService.Get(id);
            PessoaViewModel pessoaModel = mapper.Map<PessoaViewModel>(pessoa);
            return View(pessoaModel);
        }

        // POST: PessoaController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, PessoaViewModel pessoaModel)
        {
            pessoaService.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
