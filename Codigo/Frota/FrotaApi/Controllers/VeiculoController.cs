using Core;
using Core.DTO;
using Core.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace FrotaApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Motorista")]
    public class VeiculoController : ControllerBase
    {
        private readonly IVeiculoService _veiculoService;
        private readonly IPessoaService _pessoaService;
        private readonly IUnidadeAdministrativaService _unidadeService;

        public VeiculoController(
            IVeiculoService veiculoService,
            IPessoaService pessoaService,
            IUnidadeAdministrativaService unidadeService)
        {
            _veiculoService = veiculoService;
            _pessoaService = pessoaService;
            _unidadeService = unidadeService;
        }

        public class VeiculoDisponiveisResponseModel
        {
            public int TotalItems { get; set; }
            public List<Veiculo> Veiculos { get; set; }
        }

        [HttpGet("disponiveis")]
        public ActionResult<VeiculoDisponiveisResponseModel> GetVeiculosDisponiveis(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? placa = null)
        {
            try
            {
                // Obter o ID da pessoa do usuário logado
                uint pessoaId = (uint)_pessoaService.GetPessoaIdUser();
                
                // Obter a unidade administrativa e frota do motorista
                var pessoa = _pessoaService.Get(pessoaId);
                if (pessoa == null)
                {
                    return NotFound("Pessoa não encontrada");
                }

                // Obter unidade administrativa e frota
                uint idUnidadeAdm = pessoa.IdunidadeAdministrativa;
                uint idFrota = _unidadeService.Get(idUnidadeAdm)?.IdFrota ?? 0;

                if (idFrota == 0)
                {
                    return NotFound("Frota não encontrada para esta unidade administrativa");
                }

                // Buscar veículos disponíveis para a unidade administrativa do motorista
                var veiculosResult = _veiculoService.GetVeiculosDisponiveisUnidadeAdministrativaPaged(
                    page, pageSize, idFrota, idUnidadeAdm, placa ?? string.Empty);

                return Ok(new VeiculoDisponiveisResponseModel
                {
                    TotalItems = veiculosResult.TotalCount,
                    Veiculos = veiculosResult.Items.ToList()
                });
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao obter veículos: {ex.Message}");
            }
        }

        [HttpGet("{id}")]
        public ActionResult<Veiculo> GetVeiculo(uint id)
        {
            var veiculo = _veiculoService.Get(id);
            if (veiculo == null)
            {
                return NotFound("Veículo não encontrado");
            }

            return Ok(veiculo);
        }

        [HttpPost("{id}/selecionarVeiculo")]
        public ActionResult SelecionarVeiculo(uint id)
        {
            // Verificar se o veículo existe
            var veiculo = _veiculoService.Get(id);
            if (veiculo == null)
            {
                return NotFound("Veículo não encontrado");
            }

            // Verificar se o veículo está disponível
            if (veiculo.Status != "D")
            {
                return BadRequest("Este veículo não está disponível para uso");
            }

            // Registrar a seleção do veículo (no sistema web, isso redireciona para a vistoria)
            // Aqui apenas retornamos sucesso, pois o app móvel fará a navegação para a tela de vistoria
            
            return Ok(new { Message = "Veículo selecionado com sucesso", VeiculoId = id });
        }

        [HttpPost("{id}/atualizarOdometro")]
        public ActionResult AtualizarOdometro(uint id, [FromBody] int novoOdometro)
        {
            try
            {
                bool resultado = _veiculoService.AtualizarOdometroVeiculo(id, novoOdometro);
                if (resultado)
                {
                    return Ok(new { Message = "Odômetro atualizado com sucesso" });
                }
                else
                {
                    return BadRequest("Não foi possível atualizar o odômetro");
                }
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao atualizar odômetro: {ex.Message}");
            }
        }
    }
} 