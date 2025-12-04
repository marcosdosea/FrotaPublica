using Core;
using Core.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Motorista")]
    public class VistoriaController : ControllerBase
    {
        private readonly IVistoriaService _vistoriaService;
        private readonly IPessoaService _pessoaService;
        private readonly IVeiculoService _veiculoService;

        public VistoriaController(
            IVistoriaService vistoriaService,
            IPessoaService pessoaService,
            IVeiculoService veiculoService)
        {
            _vistoriaService = vistoriaService;
            _pessoaService = pessoaService;
            _veiculoService = veiculoService;
        }

        public class RegistrarVistoriaModel
        {
            public uint IdVeiculo { get; set; }
            public string Tipo { get; set; } // "Retirada" ou "Entrega"
            public string Problemas { get; set; }
        }

        [HttpPost("registrar")]
        public ActionResult RegistrarVistoria([FromBody] RegistrarVistoriaModel model)
        {
            try
            {
                // Obter a pessoa (motorista) logada
                uint idPessoa = (uint)_pessoaService.GetPessoaIdUser();

                // Verificar se o veículo existe
                var veiculo = _veiculoService.Get(model.IdVeiculo);
                if (veiculo == null)
                {
                    return NotFound("Veículo não encontrado");
                }

                // Criar a vistoria
                var vistoria = new Vistorium
                {
                    IdPessoaResponsavel = idPessoa,
                    Data = DateTime.Now,
                    Tipo = model.Tipo,
                    Problemas = model.Problemas
                };

                uint idVistoria = _vistoriaService.Create(vistoria);

                return Ok(new
                {
                    Message = $"Vistoria de {model.Tipo} registrada com sucesso",
                    IdVistoria = idVistoria
                });
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao registrar vistoria: {ex.Message}");
            }
        }

        [HttpGet("{id}")]
        public ActionResult<Vistorium> GetVistoria(uint id)
        {
            try
            {
                var vistoria = _vistoriaService.Get(id);
                if (vistoria == null)
                {
                    return NotFound("Vistoria não encontrada");
                }

                return Ok(vistoria);
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao buscar vistoria: {ex.Message}");
            }
        }

        [HttpGet("veiculo/{idVeiculo}")]
        public ActionResult<IEnumerable<Vistorium>> GetVistoriasPorVeiculo(uint idVeiculo)
        {
            try
            {
                // Verificar se o veículo existe
                var veiculo = _veiculoService.Get(idVeiculo);
                if (veiculo == null)
                {
                    return NotFound("Veículo não encontrado");
                }

                // Obter as vistorias do veículo - adaptando para o modelo atual onde não há relação direta
                var todasVistorias = _vistoriaService.GetAll(veiculo.IdFrota);
                // Como não há relação direta entre vistoria e veículo no modelo atual,
                // não é possível filtrar diretamente. Retornamos todas as vistorias da frota.

                return Ok(todasVistorias);
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao buscar vistorias: {ex.Message}");
            }
        }
    }
} 