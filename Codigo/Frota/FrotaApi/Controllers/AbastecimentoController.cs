using Microsoft.AspNetCore.Mvc;
using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;

namespace FrotaApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ABastecimentoController : ControllerBase
    {
        private readonly IAbastecimentoService _abastecimentoService;
        private readonly IMapper _mapper;

        public ABastecimentoController(IAbastecimentoService abastecimentoService, IMapper mapper)
        {
            _abastecimentoService = abastecimentoService;
            _mapper = mapper;
        }

        [HttpGet]
        public ActionResult Get()
        {
            var listaAbastecimento = _abastecimentoService.GetAll();
            if (listaAbastecimento == null)
                return NotFound();
            return Ok(listaAbastecimento);
        }

        [HttpGet("{id}")]
        public ActionResult Get(uint id)
        {
            Abastecimento abastecimento = _abastecimentoService.Get(id);
            if (abastecimento == null)
                return NotFound();
            return Ok(abastecimento);
        }

        [HttpPost]
        public ActionResult Post([FromBody] FornecedorViewModel abastecimentoModel)
        {
            if (!ModelState.IsValid)
                return BadRequest("Dados Inválidos.");

            var abastecimento = _mapper.Map<Abastecimento>(abastecimentoModel);
            _abastecimentoService.Create(abastecimento);

            return Ok();
        }

        [HttpPut("{id}")]
        public ActionResult Put(uint id, [FromBody] AbastecimentoViewModel abastecimentoModel)
        {
            if (!ModelState.IsValid)
                return BadRequest("Dados Inválidos.");

            var abastecimento = _mapper.Map<Abastecimento>(abastecimentoModel);
            if (abastecimento == null)
                return NotFound();

            _abastecimentoService.Edit(abastecimento);

            return Ok();
        }

        [HttpDelete("{id}")]
        public ActionResult Delete(uint id)
        {
            Abastecimento abastecimento = _abastecimentoService.Get(id);
            if (abastecimento == null)
                return NotFound();

            _abastecimentoService.Delete(id);
            return Ok();
        }
    }
}
