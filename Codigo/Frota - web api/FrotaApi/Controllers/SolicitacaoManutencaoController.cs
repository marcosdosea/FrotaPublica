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
    [Authorize(Roles = "Motorista")]
    public class SolicitacaoManutencaoController : ControllerBase
    {
        private readonly ISolicitacaoManutencaoService _solicitacaoManutencaoService;
        private readonly IPessoaService _pessoaService;
        private readonly IVeiculoService _veiculoService;
        private readonly IPercursoService _percursoService;

        public SolicitacaoManutencaoController(
            ISolicitacaoManutencaoService solicitacaoManutencaoService,
            IPessoaService pessoaService,
            IVeiculoService veiculoService,
            IPercursoService percursoService)
        {
            _solicitacaoManutencaoService = solicitacaoManutencaoService;
            _pessoaService = pessoaService;
            _veiculoService = veiculoService;
            _percursoService = percursoService;
        }

        public class CriarSolicitacaoManutencaoModel
        {
            public uint IdVeiculo { get; set; }
            public string Descricao { get; set; }
        }

        [HttpPost("registrar")]
        public ActionResult CriarSolicitacaoManutencao([FromBody] CriarSolicitacaoManutencaoModel model)
        {
            try
            {
                // Obter a pessoa (motorista) logada
                uint idPessoa = (uint)_pessoaService.GetPessoaIdUser();
                
                // Obter a pessoa completa para ter acesso à frota
                var pessoa = _pessoaService.Get(idPessoa);
                if (pessoa == null)
                {
                    return NotFound("Pessoa não encontrada");
                }

                // Verificar se o veículo existe
                var veiculo = _veiculoService.Get(model.IdVeiculo);
                if (veiculo == null)
                {
                    return NotFound("Veículo não encontrado");
                }

                // Verificar se o motorista está em um percurso com este veículo
                var percursoAtual = _percursoService.ObterPercursosAtualDoMotorista((int)idPessoa);
                if (percursoAtual == null || percursoAtual.IdVeiculo != model.IdVeiculo)
                {
                    return BadRequest("Você precisa estar em um percurso ativo com este veículo para solicitar manutenção");
                }

                // Criar a solicitação de manutenção
                var solicitacao = new Solicitacaomanutencao
                {
                    IdPessoa = idPessoa,
                    IdVeiculo = model.IdVeiculo,
                    DescricaoProblema = model.Descricao,
                    DataSolicitacao = DateTime.Now,
                    IdFrota = pessoa.IdFrota,
                };

                uint idSolicitacao = _solicitacaoManutencaoService.Create(solicitacao, (int)pessoa.IdFrota);

                return Ok(new
                {
                    Message = "Solicitação de manutenção criada com sucesso",
                    IdSolicitacao = idSolicitacao
                });
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao criar solicitação de manutenção: {ex.Message}");
            }
        }

        [HttpGet]
        public ActionResult<IEnumerable<Solicitacaomanutencao>> GetSolicitacoesDoMotorista()
        {
            try
            {
                // Obter a pessoa (motorista) logada
                uint idPessoa = (uint)_pessoaService.GetPessoaIdUser();
                
                // Obter a pessoa completa para ter acesso à frota
                var pessoa = _pessoaService.Get(idPessoa);
                if (pessoa == null)
                {
                    return NotFound("Pessoa não encontrada");
                }

                // Buscar todas as solicitações de manutenção da frota
                var solicitacoes = _solicitacaoManutencaoService.GetAll((int)pessoa.IdFrota)
                    .Where(s => s.IdPessoa == idPessoa)
                    .OrderByDescending(s => s.DataSolicitacao)
                    .ToList();

                return Ok(solicitacoes);
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao obter solicitações de manutenção: {ex.Message}");
            }
        }

        [HttpGet("{id}")]
        public ActionResult<Solicitacaomanutencao> GetSolicitacao(uint id)
        {
            try
            {
                var solicitacao = _solicitacaoManutencaoService.Get(id);
                if (solicitacao == null)
                {
                    return NotFound("Solicitação de manutenção não encontrada");
                }

                // Verificar se a solicitação pertence ao motorista logado
                uint idPessoa = (uint)_pessoaService.GetPessoaIdUser();
                if (solicitacao.IdPessoa != idPessoa)
                {
                    return Forbid("Você não tem permissão para visualizar esta solicitação");
                }

                return Ok(solicitacao);
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao obter solicitação de manutenção: {ex.Message}");
            }
        }
    }
}
