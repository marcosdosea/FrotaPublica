using System;
using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{
    [Authorize(Roles = "Gestor,Motorista")]
    public class VeiculoController : Controller
    {
        private readonly IVeiculoService veiculoService;
        private readonly IMapper mapper;
        private readonly IUnidadeAdministrativaService unidadeAdministrativaService;
        private readonly IPessoaService pessoaService;
        private readonly IFrotaService frotaService;
        private readonly IModeloVeiculoService modeloVeiculoService;
        private readonly IPercursoService percursoService;
        private readonly IVistoriaService vistoriaService;
        private readonly IAbastecimentoService abastecimentoService;
        private readonly ISolicitacaoManutencaoService solicitacaoManutencaoService;
        private readonly IFornecedorService fornecedorService;

        public VeiculoController(IVeiculoService service, IMapper mapper, IUnidadeAdministrativaService unidadeAdministrativaService, IFrotaService frotaService, IModeloVeiculoService modeloVeiculoService, IPessoaService pessoaService, IPercursoService percursoService, IVistoriaService vistoriaService, IAbastecimentoService abastecimentoService, ISolicitacaoManutencaoService solicitacaoManutencaoService, IFornecedorService fornecedorService)
        {
            this.veiculoService = service;
            this.mapper = mapper;
            this.unidadeAdministrativaService = unidadeAdministrativaService;
            this.frotaService = frotaService;
            this.modeloVeiculoService = modeloVeiculoService;
            this.pessoaService = pessoaService;
            this.percursoService = percursoService;
            this.vistoriaService = vistoriaService;
            this.abastecimentoService = abastecimentoService;
            this.solicitacaoManutencaoService = solicitacaoManutencaoService;
            this.fornecedorService = fornecedorService;
        }

        // GET: Veiculo
        [Route("Veiculo/Index/{page}")]
        [Route("Veiculo/{page}")]
        [Route("Veiculo")]
        public ActionResult Index([FromRoute] int page = 0)
        {
            uint.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);

            int length = 15;
            var listaVeiculos = veiculoService.GetPaged(page, length, idFrota).ToList();

            var totalVeiculos = veiculoService.GetAll(idFrota).Count();
            var totalPages = (int)Math.Ceiling((double)totalVeiculos / length);

            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = totalPages;
            var veiculosViewModel = mapper.Map<List<VeiculoViewModel>>(listaVeiculos);
            foreach (var veiculo in veiculosViewModel)
            {
                veiculo.ModeloNome = modeloVeiculoService.Get(veiculo.IdModeloVeiculo).Nome;
                string status;
                if(veiculo.Status == "D")
                {
                    veiculo.StatusNome = "Disponível";
                }
                else if (veiculo.Status == "U")
                {
                    veiculo.StatusNome = "Em Uso";
                }
                else if (veiculo.Status == "M")
                {
                    veiculo.StatusNome = "Em Manutenção";
                }
                else
                {
                    veiculo.StatusNome = "Indisponível";
                }
            }
            return View(veiculosViewModel);
        }

        [Authorize(Roles = "Gestor,Motorista")]
        [Route("Veiculo/Disponiveis")]
        [Route("Veiculo/Disponiveis/{page}")]
        public ActionResult VeiculosDisponiveis([FromRoute] int page = 0, [FromQuery] string placa = "")
        {
            uint.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            uint.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "UnidadeId")?.Value, out uint idUnidade);

            int length = 15;
            var pagedResult = veiculoService.GetVeiculosDisponiveisUnidadeAdministrativaPaged(page, length, idFrota, idUnidade, placa);

            var totalPages = (int)Math.Ceiling((double)pagedResult.TotalCount / length);

            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = totalPages;
            ViewBag.CurrentPlaca = placa;

            var veiculosViewModel = mapper.Map<List<VeiculoViewModel>>(pagedResult.Items);

            foreach (var veiculo in veiculosViewModel)
            {
                veiculo.ModeloNome = modeloVeiculoService.Get(veiculo.IdModeloVeiculo).Nome;
                veiculo.StatusNome = "Disponível";
            }
            return View(veiculosViewModel);
        }

        [Route("Veiculo/Gerenciamento/{idPercurso}/{idVeiculo}")]
        public IActionResult Gerenciamento(uint idPercurso, uint idVeiculo)
        {
            var veiculo = veiculoService.Get(idVeiculo);
            var percurso = percursoService.Get(idPercurso);
            
            if (veiculo == null || percurso == null)
            {
                return NotFound();
            }

            var veiculoViewModel = mapper.Map<VeiculoViewModel>(veiculo);
            veiculoViewModel.ModeloNome = modeloVeiculoService.Get(veiculo.IdModeloVeiculo).Nome;
            ViewBag.IdPercursoAtual = idPercurso;
            ViewBag.Percurso = percurso;
            return View(veiculoViewModel);
        }

        [HttpGet]
        [Route("Veiculo/RegistrarVistoria/{idPercurso}/{idVeiculo}")]
        public IActionResult RegistrarVistoria(uint idPercurso, uint idVeiculo)
        {
            var vistoriaViewModel = new VistoriaViewModel
            {
                IdPessoaResponsavel = pessoaService.GetPessoaIdUser(),
                Data = DateTime.Now
            };
            ViewBag.IdPercurso = idPercurso;
            ViewBag.IdVeiculo = idVeiculo;
            return View(vistoriaViewModel);
        }

        [HttpPost]
        [Route("Veiculo/RegistrarVistoria/{idPercurso}/{idVeiculo}")]
        [ValidateAntiForgeryToken]
        public IActionResult RegistrarVistoria(uint idPercurso, uint idVeiculo, VistoriaViewModel vistoriaViewModel)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    var vistoria = mapper.Map<Vistorium>(vistoriaViewModel);
                    vistoriaService.Create(vistoria);
                    return RedirectToAction("Gerenciamento", new { idPercurso, idVeiculo });
                }
                catch (ServiceException exception)
                {
                    ModelState.AddModelError(exception.AtributoError!, exception.MensagemCustom);
                }
            }
            ViewBag.IdPercurso = idPercurso;
            ViewBag.IdVeiculo = idVeiculo;
            return View(vistoriaViewModel);
        }

        [HttpGet]
        [Route("Veiculo/RegistrarAbastecimento/{idPercurso}/{idVeiculo}")]
        public IActionResult RegistrarAbastecimento(uint idPercurso, uint idVeiculo)
        {
            var abastecimentoViewModel = new AbastecimentoViewModel
            {
                IdVeiculo = idVeiculo,
                IdPessoa = pessoaService.GetPessoaIdUser(),
                DataHora = DateTime.Now
            };
            ViewBag.IdVeiculo = idVeiculo;
            ViewBag.IdPercurso = idPercurso;
            ViewBag.Fornecedores = fornecedorService.GetAllOrdemAlfabetica((int)veiculoService.Get(idVeiculo).IdFrota);
            return View(abastecimentoViewModel);
        }

        [HttpPost]
        [Route("Veiculo/RegistrarAbastecimento/{idPercurso}/{idVeiculo}")]
        [ValidateAntiForgeryToken]
        public IActionResult RegistrarAbastecimento(uint idPercurso, uint idVeiculo, AbastecimentoViewModel abastecimentoViewModel)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    var abastecimento = mapper.Map<Abastecimento>(abastecimentoViewModel);
                    abastecimento.IdFrota = veiculoService.Get(idVeiculo).IdFrota;

                    //atualizar o odometro do veículo
                    if (!veiculoService.AtualizarOdometroVeiculo(abastecimento.IdVeiculo, abastecimento.Odometro))
                    {
                        ViewBag.IdVeiculo = idVeiculo;
                        ViewBag.IdPercurso = idPercurso;
                        ViewBag.Fornecedores = fornecedorService.GetAllOrdemAlfabetica((int)veiculoService.Get(idVeiculo).IdFrota);
                        return View(abastecimentoViewModel);
                    }

                    abastecimentoService.Create(abastecimento);
                    return RedirectToAction("Gerenciamento", new { idPercurso, idVeiculo });
                }
                catch (ServiceException exception)
                {
                    ModelState.AddModelError(exception.AtributoError!, exception.MensagemCustom);
                }
            }
            ViewBag.IdVeiculo = idVeiculo;
            ViewBag.IdPercurso = idPercurso;
            ViewBag.Fornecedores = fornecedorService.GetAllOrdemAlfabetica((int)veiculoService.Get(idVeiculo).IdFrota);
            return View(abastecimentoViewModel);
        }

        [HttpGet]
        [Route("Veiculo/SolicitarManutencao/{idPercurso}/{idVeiculo}")]
        public IActionResult SolicitarManutencao(uint idPercurso, uint idVeiculo)
        {
            var solicitacaoViewModel = new SolicitacaoManutencaoViewModel
            {
                IdVeiculo = idVeiculo,
                IdPessoa = pessoaService.GetPessoaIdUser(),
                DataSolicitacao = DateTime.Now
            };
            ViewBag.IdVeiculo = idVeiculo;
            ViewBag.IdPercurso = idPercurso;
            return View(solicitacaoViewModel);
        }

        [HttpPost]
        [Route("Veiculo/SolicitarManutencao/{idPercurso}/{idVeiculo}")]
        [ValidateAntiForgeryToken]
        public IActionResult SolicitarManutencao(uint idPercurso, uint idVeiculo, SolicitacaoManutencaoViewModel solicitacaoViewModel)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    var solicitacao = mapper.Map<Solicitacaomanutencao>(solicitacaoViewModel);
                    solicitacaoManutencaoService.Create(solicitacao, (int)veiculoService.Get(idVeiculo).IdFrota);
                    return RedirectToAction("Gerenciamento", new { idPercurso, idVeiculo });
                }
                catch (ServiceException exception)
                {
                    ModelState.AddModelError(exception.AtributoError!, exception.MensagemCustom);
                }
            }
            ViewBag.IdVeiculo = idVeiculo;
            ViewBag.IdPercurso = idPercurso;
            return View(solicitacaoViewModel);
        }

        [HttpGet]
        [Route("Veiculo/FinalizarUso/{idPercurso}/{idVeiculo}")]
        public IActionResult FinalizarUso(uint idPercurso, uint idVeiculo)
        {
            var percurso = percursoService.Get(idPercurso);
            var veiculo = veiculoService.Get(idVeiculo);
            
            if (percurso == null || veiculo == null)
            {
                return NotFound();
            }

            var percursoViewModel = mapper.Map<PercursoViewModel>(percurso);
            percursoViewModel.DataHoraRetorno = DateTime.Now;
            percursoViewModel.OdometroFinal = veiculo.Odometro;
            
            ViewBag.IdPercurso = idPercurso;
            ViewBag.IdVeiculo = idVeiculo;
            return View(percursoViewModel);
        }

        [HttpPost]
        [Route("Veiculo/FinalizarUso/{idPercurso}/{idVeiculo}")]
        [ValidateAntiForgeryToken]
        public IActionResult FinalizarUso(uint idPercurso, uint idVeiculo, PercursoViewModel percursoViewModel)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    var percurso = mapper.Map<Percurso>(percursoViewModel);
                    percursoService.Edit(percurso);
                    
                    var veiculo = veiculoService.Get(idVeiculo);
                    veiculo.Status = "D"; // Disponível
                    veiculo.Odometro = percursoViewModel.OdometroFinal;
                    veiculoService.Edit(veiculo);
                    
                    return RedirectToAction("VeiculosDisponiveis");
                }
                catch (ServiceException exception)
                {
                    ModelState.AddModelError(exception.AtributoError!, exception.MensagemCustom);
                }
            }
            ViewBag.IdPercurso = idPercurso;
            ViewBag.IdVeiculo = idVeiculo;
            return View(percursoViewModel);
        }

        // GET: Veiculo/Details/5
        public ActionResult Details(uint id)
        {
            var veiculo = veiculoService.Get(id);
            var veiculoViewModel = mapper.Map<VeiculoViewModel>(veiculo);
            return View(veiculoViewModel);
        }

        // GET: Veiculo/Create
        [Route("Veiculo/Create")]
        public ActionResult Create()
        {
            uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            ViewData["Unidades"] = this.unidadeAdministrativaService.GetAllOrdemAlfabetica(idFrota);
            ViewData["Modelos"] = this.modeloVeiculoService.GetAllOrdemAlfabetica(idFrota);
            return View();
        }

        // POST: Veiculo/Create
        [HttpPost]
        [Route("Veiculo/Create")]
        [ValidateAntiForgeryToken]
        public ActionResult Create(VeiculoViewModel veiculoViewModel)
        {
            if (ModelState.IsValid)
            {
                uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
                var veiculo = mapper.Map<Veiculo>(veiculoViewModel);
                veiculo.IdFrota = idFrota;
                TempData["MensagemSucesso"] = "Veículo cadastrado com sucesso!";
                try
                {
                    veiculoService.Create(veiculo);
                }
                catch (ServiceException exception)
                {
                    ModelState.AddModelError(exception.AtributoError!, "Este dado já está cadastrado");
                    ViewData["Unidades"] = this.unidadeAdministrativaService.GetAllOrdemAlfabetica(idFrota);
                    ViewData["Modelos"] = this.modeloVeiculoService.GetAllOrdemAlfabetica(idFrota);
                    return View(veiculoViewModel);
                }

            }
            return RedirectToAction(nameof(Index));
        }

        // GET: Veiculo/Edit/5
        public ActionResult Edit(uint id)
        {
            var veiculo = veiculoService.Get(id);
            var veiculoViewModel = mapper.Map<VeiculoViewModel>(veiculo);
            ViewData["Unidades"] = this.unidadeAdministrativaService.GetAllOrdemAlfabetica(veiculoViewModel.IdFrota);
            ViewData["Modelos"] = this.modeloVeiculoService.GetAllOrdemAlfabetica(veiculoViewModel.IdFrota);
            return View(veiculoViewModel);
        }

        // POST: Veiculo/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, VeiculoViewModel veiculoViewModel)
        {
            if (ModelState.IsValid)
            {
                uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
                veiculoViewModel.IdFrota = idFrota;
                var veiculo = mapper.Map<Veiculo>(veiculoViewModel);
                try
                {
                    veiculoService.Edit(veiculo);
                }
                catch (ServiceException exception)
                {
                    ModelState.AddModelError(exception.AtributoError!, "Este dado já está cadastrado");
                    ViewData["Unidades"] = this.unidadeAdministrativaService.GetAllOrdemAlfabetica((uint)veiculo.IdFrota);
                    ViewData["Modelos"] = this.modeloVeiculoService.GetAllOrdemAlfabetica((uint)veiculo.IdFrota);
                    return View(veiculoViewModel);
                }
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: Veiculo/Delete/5
        public ActionResult Delete(uint id)
        {
            var veiculo = veiculoService.Get(id);
            var veiculoViewModel = mapper.Map<VeiculoViewModel>(veiculo);
            return View(veiculoViewModel);
        }

        // POST: Veiculo/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, VeiculoViewModel veiculoViewModel)
        {
            try
            {
                veiculoService.Delete(id);
                TempData["MensagemSucesso"] = "Veículo removido com sucesso!";
            }
            catch (ServiceException exception)
            {
                TempData["MensagemError"] = exception.MensagemCustom;
            }
            return RedirectToAction(nameof(Index));
        }

        [HttpGet]
        [Route("Veiculo/Usar/{id}")]
        public IActionResult Usar(uint id)
        {
            var veiculo = veiculoService.Get(id);
            if (veiculo == null)
            {
                return NotFound();
            }

            var veiculoViewModel = mapper.Map<VeiculoViewModel>(veiculo);
            veiculoViewModel.ModeloNome = modeloVeiculoService.Get(veiculo.IdModeloVeiculo).Nome;
            ViewBag.IdVeiculo = id;
            return View("Gerenciamento", veiculoViewModel);
        }

        [HttpGet]
        [Route("Veiculo/RegistrarSaida/{idVeiculo}")]
        public IActionResult RegistrarSaida(uint idVeiculo)
        {
            var veiculo = veiculoService.Get(idVeiculo);
            if (veiculo == null)
            {
                return NotFound();
            }
            var percursoViewModel = new PercursoViewModel
            {
                IdVeiculo = idVeiculo,
                IdPessoa = pessoaService.GetPessoaIdUser(),
                DataHoraSaida = DateTime.Now,
                OdometroInicial = veiculo.Odometro
            };
            ViewBag.IdVeiculo = idVeiculo;
            return View(percursoViewModel);
        }

        [HttpPost]
        [Route("Veiculo/RegistrarSaida/{idVeiculo}")]
        [ValidateAntiForgeryToken]
        public IActionResult RegistrarSaida(uint idVeiculo, PercursoViewModel percursoViewModel)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    var percurso = mapper.Map<Percurso>(percursoViewModel);
                    percursoService.Create(percurso);
                    var veiculo = veiculoService.Get(idVeiculo);
                    veiculo.Status = "U"; // Em Uso
                    veiculoService.Edit(veiculo);
                    return RedirectToAction("Gerenciamento", new { idPercurso = percurso.Id, idVeiculo = idVeiculo });
                }
                catch (ServiceException exception)
                {
                    ModelState.AddModelError(exception.AtributoError!, exception.MensagemCustom);
                    ViewBag.IdVeiculo = idVeiculo;
                    return View(percursoViewModel);
                }
            }
            ViewBag.IdVeiculo = idVeiculo;
            return View(percursoViewModel);
        }
    }
}

