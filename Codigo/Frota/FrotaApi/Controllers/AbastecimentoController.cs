using Microsoft.AspNetCore.Mvc;
using AutoMapper;
using Core;
using Core.Service;
using FrotaApi.Models;
using Microsoft.AspNetCore.Authorization;

namespace FrotaApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Gestor, Motorista")]
    public class AbastecimentoController : ControllerBase
    {
        private readonly IAbastecimentoService _abastecimentoService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IMapper _mapper;
        private readonly IPessoaService _pessoaService;

        public AbastecimentoController(IAbastecimentoService abastecimentoService,
            IHttpContextAccessor httpContextAccessor,
            IMapper mapper,
            IPessoaService pessoaService)
        {
            _mapper = mapper;
            _httpContextAccessor = httpContextAccessor;
            _abastecimentoService = abastecimentoService;
            _pessoaService = pessoaService;
        }

        // GET: api/AbastecimentoApi
        [HttpGet]
        public ActionResult<IEnumerable<AbastecimentoViewModel>> GetAll()
        {
            uint idFrota = 1;
            var listaAbastecimentos = _abastecimentoService.GetAll(idFrota).ToList();
            var listaAbastecimentosViewModel = _mapper.Map<List<AbastecimentoViewModel>>(listaAbastecimentos);
            return Ok(listaAbastecimentosViewModel);
        }

        // GET: api/AbastecimentoApi/5
        [HttpGet("{id}")]
        public ActionResult<AbastecimentoViewModel> Get(uint id)
        {
            var abastecimento = _abastecimentoService.Get(id);

            if (abastecimento == null)
            {
                return NotFound();
            }

            var abastecimentoView = _mapper.Map<AbastecimentoViewModel>(abastecimento);
            return Ok(abastecimentoView);
        }

        // POST: api/AbastecimentoApi
        [HttpPost]
        public ActionResult<AbastecimentoViewModel> Create(AbastecimentoViewModel abastecimentoViewModel)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            uint.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            string cpf = _httpContextAccessor.HttpContext?.User.Identity?.Name!;

            var abastecimento = _mapper.Map<Abastecimento>(abastecimentoViewModel);
            abastecimento.IdFrota = idFrota;
            abastecimento.IdPessoa = _pessoaService.GetIdPessoaByCpf(cpf);

            _abastecimentoService.Create(abastecimento);

            var createdAbastecimento = _abastecimentoService.Get(abastecimento.Id);
            var result = _mapper.Map<AbastecimentoViewModel>(createdAbastecimento);

            return CreatedAtAction(nameof(Get), new { id = result.Id }, result);
        }

        // PUT: api/AbastecimentoApi/5
        [HttpPut("{id}")]
        public IActionResult Update(uint id, AbastecimentoViewModel abastecimentoViewModel)
        {
            if (id != abastecimentoViewModel.Id)
            {
                return BadRequest("ID na rota não corresponde ao ID no objeto");
            }

            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var existingAbastecimento = _abastecimentoService.Get(id);
            if (existingAbastecimento == null)
            {
                return NotFound();
            }

            uint.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            var abastecimento = _mapper.Map<Abastecimento>(abastecimentoViewModel);
            abastecimento.IdFrota = idFrota;

            _abastecimentoService.Edit(abastecimento);

            return NoContent();
        }

        // DELETE: api/AbastecimentoApi/5
        [HttpDelete("{id}")]
        public IActionResult Delete(uint id)
        {
            var abastecimento = _abastecimentoService.Get(id);

            if (abastecimento == null)
            {
                return NotFound();
            }

            _abastecimentoService.Delete(id);

            return NoContent();
        }
    }
}
