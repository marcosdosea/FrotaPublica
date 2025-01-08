using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;


namespace FrotaWeb.Controllers
{

    [Authorize(Roles = "Gestor")]
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
        [Route("Pessoa/Index/{page}")]
        [Route("Pessoa/{page}")]
        [Route("Pessoa")]
        public ActionResult Index([FromRoute] int page = 0, string search = null, string filterBy = "Nome")
        {
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
            int length = 13;
            int totalResultados;
            var listaPessoas = pessoaService.GetPaged(idFrota, page, length, out totalResultados, search, filterBy).ToList();

            var totalPessoas = pessoaService.GetAll(idFrota).Count();
            var totalPages = (int)Math.Ceiling((double)totalResultados / length);

            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = totalPages;
            ViewBag.Search = search;
            ViewBag.FilterBy = filterBy;
            ViewBag.Resultados = listaPessoas.Count();

            var listaPessoasModel = mapper.Map<List<PessoaViewModel>>(listaPessoas);
            foreach (var item in listaPessoasModel)
            {
                item.StatusAtivo = item.Ativo == 1 ? "Ativo" : "Desativado";
            }
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
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);

            if (ModelState.IsValid)
            {
                var pessoa = mapper.Map<Pessoa>(pessoaModel);
                pessoaService.Create(pessoa, idFrota);
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
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);

            if (ModelState.IsValid)
            {
                var pessoa = mapper.Map<Pessoa>(pessoaModel);
                pessoaService.Edit(pessoa, idFrota);
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
