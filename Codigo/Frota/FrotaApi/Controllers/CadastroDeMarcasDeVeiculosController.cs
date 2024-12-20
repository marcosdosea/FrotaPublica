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
    [Authorize]
    public class CadastroDeMarcasDeVeículosController : ControllerBase
    {
        private readonly IMarcaVeiculoService _marcaVeiculoService;
        private readonly IMapper _mapper;

        public CadastroDeMarcasDeVeículosController(IMarcaVeiculoService marcaVeiculoService, IMapper mapper)
        {
            _marcaVeiculoService = marcaVeiculoService;
            _mapper = mapper;
        }

        [HttpGet]
        public ActionResult Get()
        {
            var listaMarcas = _marcaVeiculoService.GetAll();
            if (listaMarcas == null)
                return NotFound();
            return Ok(listaMarcas);
        }

        [HttpGet("{id}")]
        public ActionResult Get(uint id)
        {
            Marcaveiculo marca = _marcaVeiculoService.Get(id);
            if (marca == null)
                return NotFound();
            return Ok(marca);
        }

        [HttpPost]
        public ActionResult Post([FromBody] MarcaVeiculoViewModel marcaModel)
        {
            if (!ModelState.IsValid)
                return BadRequest("Dados Inválidos.");

            var marcaveiculo = _mapper.Map<Marcaveiculo>(marcaModel);
            _marcaVeiculoService.Create(marcaveiculo);

            return Ok();
        }

        [HttpPut("{id}")]
        public ActionResult Put(uint id, [FromBody] MarcaVeiculoViewModel marcaModel)
        {
            if (!ModelState.IsValid)
                return BadRequest("Dados Inválidos.");

            var marcaVeiculo = _mapper.Map<Marcaveiculo>(marcaModel);
            if (marcaVeiculo == null)
                return NotFound();

            _marcaVeiculoService.Edit(marcaVeiculo);

            return Ok();
        }

        [HttpDelete("{id}")]
        public ActionResult Delete(uint id)
        {
            Marcaveiculo marca = _marcaVeiculoService.Get(id);
            if (marca == null)
                return NotFound();

            _marcaVeiculoService.Delete(id);
            return Ok();
        }
    }
}
