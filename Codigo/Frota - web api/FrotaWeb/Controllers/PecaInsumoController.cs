using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{
    [Authorize(Roles = "Administrador")]
    public class PecaInsumoController : Controller
    {
        private readonly IPecaInsumoService _pecaInsumoService;
        private readonly IMapper _mapper;

        public PecaInsumoController(IPecaInsumoService pecaInsumoService, IMapper mapper)
        {
            _pecaInsumoService = pecaInsumoService;
            _mapper = mapper;
        }

        // GET: PecaInsumoController
        public ActionResult Index()
        {
            uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            if (idFrota == 0)
            {
                return Redirect("/Identity/Account/Login");
            }
            var listaPeca = _pecaInsumoService.GetAll(idFrota);            
            var listaPecaModel = _mapper.Map<List<PecaInsumoViewModel>>(listaPeca);
            return View(listaPecaModel);
        }

        // GET: PecaInsumoController/Details/5
        public ActionResult Details(uint id)
        {
            Pecainsumo? pecainsumo = _pecaInsumoService.Get(id);
            PecaInsumoViewModel pecainsumoModel = _mapper.Map<PecaInsumoViewModel>(pecainsumo);
            return View(pecainsumoModel);
        }

        // GET: PecaInsumoController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: PecaInsumoController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(PecaInsumoViewModel model)
        {
            if (ModelState.IsValid)
            {
                uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
                try
                {
                    var peca = _mapper.Map<Pecainsumo>(model);
                    peca.IdFrota = idFrota;
                    _pecaInsumoService.Create(peca);
                }
                catch (ServiceException exception)
                {
                    return View(model);
                }
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: PecaInsumoController/Edit/5
        public ActionResult Edit(uint id)
        {
            Pecainsumo? pecainsumo = _pecaInsumoService.Get(id);
            PecaInsumoViewModel pecaInsumoViewModel = _mapper.Map<PecaInsumoViewModel>(pecainsumo);
            return View(pecaInsumoViewModel);
        }

        // POST: PecaInsumoController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, PecaInsumoViewModel model)
        {
            uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            if (ModelState.IsValid)
            {
                try
                {
                    var peca = _mapper.Map<Pecainsumo>(model);
                    peca.IdFrota = idFrota;
                    _pecaInsumoService.Edit(peca);
                }
                catch (ServiceException exception)
                {
                    return View(model);
                }
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: PecaInsumoController/Delete/5
        public ActionResult Delete(uint id)
        {
            Pecainsumo? pecainsumo = _pecaInsumoService.Get(id);
            PecaInsumoViewModel pecaInsumoViewModel = _mapper.Map<PecaInsumoViewModel>(pecainsumo);
            return View(pecaInsumoViewModel);
        }

        // POST: PecaInsumoController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, PecaInsumoViewModel model)
        {
            _pecaInsumoService.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
