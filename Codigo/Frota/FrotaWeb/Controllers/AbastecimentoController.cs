using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{

    [Authorize(Roles = "Gestor, Motorista")]
    public class AbastecimentoController : Controller
    {
        private readonly IAbastecimentoService abastecimentoService;
        private readonly IHttpContextAccessor httpContextAccessor;
        private readonly IMapper mapper;
        private readonly IPessoaService pessoaService;

        public AbastecimentoController(IAbastecimentoService abastecimentoService, IHttpContextAccessor httpContextAccessor, IMapper mapper, IPessoaService pessoaService)
        {
            this.mapper = mapper;
            this.httpContextAccessor = httpContextAccessor;
            this.abastecimentoService = abastecimentoService;
            this.pessoaService = pessoaService;
        }
        // GET: AbastecimentoController
        public ActionResult Index()
        {
            uint.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
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
                uint.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
                string cpf = httpContextAccessor.HttpContext?.User.Identity?.Name!;
                var abastecimento = mapper.Map<Abastecimento>(abastecimentoViewModel);
                abastecimento.IdFrota = idFrota;
                abastecimento.IdPessoa = pessoaService.GetIdPessoaByCpf(cpf);
                abastecimentoService.Create(abastecimento);
                TempData["MensagemSucesso"] = "Abastecimento cadastrado com sucesso!";
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
                uint.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
                var abastecimento = mapper.Map<Abastecimento>(abastecimentoViewModel);
                abastecimento.IdFrota = idFrota;
                abastecimentoService.Edit(abastecimento);
                TempData["MensagemSucesso"] = "Abastecimento alterado com sucesso!";
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
            TempData["MensagemSucesso"] = "Abastecimento removido com sucesso!";
            abastecimentoService.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
