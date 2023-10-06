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
    public class AbastecimentoController : Controller
    {
        private readonly IAbastecimentoService _abastecimentoService;
        private readonly IMapper _mapper;
        public AbastecimentoController(IAbastecimentoService abastecimentoService, IMapper mapper)
        {
            _mapper = mapper;
            _abastecimentoService = abastecimentoService;
        }
        // GET: AbastecimentoController
        public ActionResult Index()
        {
            var listAbastecimento = _abastecimentoService.GetAll();
            var listView = _mapper.Map<List<AbastecimentoViewModel>>(listAbastecimento);
            return View(listView);
        }

        public ActionResult Abastecer(AbastecimentoViewModel abastecimento)
        {
            var _abastecimento = _mapper.Map<Abastecimento>(abastecimento);

            return View();

        }
        // GET: AbastecimentoController/Details/5
        public ActionResult Details(uint id)
        {
            var abastecimento = _abastecimentoService.Get(id);
            var abastecimentoView = _mapper.Map<AbastecimentoViewModel>(abastecimento);
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
        public ActionResult Create(AbastecimentoViewModel abastecimento)
        {
            if (ModelState.IsValid)
            {
                var _abastecimento = _mapper.Map<Abastecimento>(abastecimento);
                _abastecimento.DataHora = DateTime.Now;
                _abastecimento.IdVeiculoPercurso = 1;
                _abastecimento.IdPessoaPercurso = 1;
                _abastecimento.IdFornecedor = 1;
               // _abastecimento.IdFornecedorNavigation = Fornecedor;
                _abastecimento.Id = 1;
                _abastecimento.Id =  1;
            }

            return RedirectToAction(nameof(Index));
        }

        // GET: AbastecimentoController/Edit/5
        public ActionResult Edit(uint id)
        {
            var abastecimento = _abastecimentoService.Get(id);
            var abastecimentoView = _mapper.Map<AbastecimentoViewModel>(abastecimento);
            return View(abastecimentoView);
        }

        // POST: AbastecimentoController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, AbastecimentoViewModel abastecimento)
        {
            if (ModelState.IsValid)
            {
                var _abastecimento = _mapper.Map<Abastecimento>(abastecimento);
                _abastecimentoService.Create(_abastecimento);
            }

            return RedirectToAction(nameof(Index));
        }

        // GET: AbastecimentoController/Delete/5
        public ActionResult Delete(uint id)
        {
            var abastecimento = _abastecimentoService.Get(id);
            var abastecimentoViewModel = _mapper.Map<AbastecimentoViewModel>(abastecimento);
            return View(abastecimentoViewModel);
        }

        // POST: AbastecimentoController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, Abastecimento abastecimento)
        {
            _abastecimentoService.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
