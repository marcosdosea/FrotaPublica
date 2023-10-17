using AutoMapper;
using Core;
using Core.Service;
using FrotaApi.Models;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace FrotaApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ModeloVeiculoController : ControllerBase
    {

        private readonly IModeloVeiculoService _modeloveiculoservice;
        private readonly IMapper _mapper;

        public ModeloVeiculoController(IModeloVeiculoService modeloveiculoservice, IMapper mapper)
        {
            this._modeloveiculoservice = modeloveiculoservice;
            this._mapper = mapper;
        }


        // GET: api/<ModeloVeiculoController>
        [HttpGet]
        public ActionResult Get()
        {
            var listaModelosVeiculos = _modeloveiculoservice.GetAll();
            if (listaModelosVeiculos == null)
                return NotFound();
            return Ok(listaModelosVeiculos);
        }

        // GET api/<ModeloVeiculoController>/5
        [HttpGet("{id}")]
        public ActionResult Get(uint id)
        {
            Modeloveiculo modelo = _modeloveiculoservice.Get(id);
            if (modelo == null)
                return NotFound();
            return Ok(modelo);
        }


        // POST api/<ModeloVeiculoController>
        [HttpPost]
        public ActionResult Post([FromBody] ModeloVeiculoViewModel modeloVeiculomodel)
        {
            if (!ModelState.IsValid)
                return BadRequest("Dados Invalidos.");

            var modelVeiculo = _mapper.Map<Modeloveiculo>(modeloVeiculomodel);
            _modeloveiculoservice.Create(modelVeiculo);

            return Ok();

        }

        // PUT api/<ModeloVeiculoController>/5
        [HttpPut("{id}")]
        public ActionResult Put(uint id, [FromBody] ModeloVeiculoViewModel modeloVeiculomodel)
        {
            if (!ModelState.IsValid)
                return BadRequest("Dados Invalidos.");

            var modeloVeiculo = _mapper.Map<Modeloveiculo>(modeloVeiculomodel);
            if (modeloVeiculo == null)
                return NotFound();

            _modeloveiculoservice.Edit(modeloVeiculo);

            return Ok();

        }

        // DELETE api/<ModeloVeiculoController>/5
        [HttpDelete("{id}")]
        public ActionResult Delete(uint id)
        {
            Modeloveiculo modeloVeiculo = _modeloveiculoservice.Get(id);
            if (modeloVeiculo == null)
                return NotFound();

            _modeloveiculoservice.Delete(id);
            return Ok();
        }
    }
}
