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
    public class ModeloVeiculoController : ControllerBase
    {
        private readonly IModeloVeiculoService _modeloveiculoservice;
        private readonly IVeiculoService _veiculoService;
        private readonly IMapper _mapper;

        public ModeloVeiculoController(IModeloVeiculoService modeloveiculoservice, IVeiculoService veiculoService, IMapper mapper)
        {
            this._modeloveiculoservice = modeloveiculoservice;
            this._veiculoService = veiculoService;
            this._mapper = mapper;
        }

        [HttpGet("{id}")]
        public ActionResult<string> GetModeloVeiculo(int id)
        {
            var veiculo = _veiculoService.Get((uint)id);
            if (veiculo == null)
            {
                return NotFound("Veículo não encontrado");
            }

            var modelo = _modeloveiculoservice.Get(veiculo.IdModeloVeiculo);
            if (modelo == null)
            {
                return NotFound("Modelo do veículo não encontrado");
            }

            return Ok(modelo.Nome);
        }
    }
}
