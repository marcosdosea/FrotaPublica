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
    public class AbastecimentoController : ControllerBase
    {
        private readonly IAbastecimentoService _abastecimentoService;
        private readonly IPessoaService _pessoaService;
        private readonly IVeiculoService _veiculoService;
        private readonly IPercursoService _percursoService;
        private readonly IMapper _mapper;

        public AbastecimentoController(
            IAbastecimentoService abastecimentoService,
            IPessoaService pessoaService,
            IVeiculoService veiculoService,
            IPercursoService percursoService,
            IMapper mapper)
        {
            _abastecimentoService = abastecimentoService;
            _pessoaService = pessoaService;
            _veiculoService = veiculoService;
            _percursoService = percursoService;
            _mapper = mapper;
        }

        public class RegistrarAbastecimentoModel
        {
            public uint IdVeiculo { get; set; }
            public uint IdFornecedor { get; set; }
            public DateTime Data { get; set; }
            public decimal ValorLitro { get; set; }
            public decimal Litros { get; set; }
            public decimal KmAtual { get; set; }
            public string? Observacoes { get; set; }
            public uint? IdPercurso { get; set; }
        }

        // GET: api/Abastecimento
        [HttpGet]
        public ActionResult<IEnumerable<Abastecimento>> GetAbastecimentosDoMotorista()
        {
            try
            {
                // Obter a pessoa (motorista) logada
                uint idPessoa = (uint)_pessoaService.GetPessoaIdUser();
                
                // Obter a unidade administrativa e frota do motorista
                var pessoa = _pessoaService.Get(idPessoa);
                if (pessoa == null)
                {
                    return NotFound("Pessoa não encontrada");
                }

                uint idFrota = pessoa.IdFrota;

                // Buscar todos os abastecimentos da frota
                var abastecimentos = _abastecimentoService.GetAll(idFrota)
                    .Where(a => a.IdPessoa == idPessoa)
                    .OrderByDescending(a => a.DataHora)
                    .ToList();

                return Ok(abastecimentos);
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao obter abastecimentos: {ex.Message}");
            }
        }

        // GET: api/Abastecimento/5
        [HttpGet("{id}")]
        public ActionResult<Abastecimento> GetAbastecimento(uint id)
        {
            try
            {
                var abastecimento = _abastecimentoService.Get(id);
                if (abastecimento == null)
                {
                    return NotFound("Abastecimento não encontrado");
                }

                // Verificar se o abastecimento pertence ao motorista logado
                uint idPessoa = (uint)_pessoaService.GetPessoaIdUser();
                if (abastecimento.IdPessoa != idPessoa)
                {
                    return Forbid("Você não tem permissão para visualizar este abastecimento");
                }

                return Ok(abastecimento);
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao obter abastecimento: {ex.Message}");
            }
        }

        // POST: api/Abastecimento
        [HttpPost]
        public ActionResult<Abastecimento> RegistrarAbastecimento([FromBody] RegistrarAbastecimentoModel model)
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

                // Verificar se o fornecedor foi informado
                if (model.IdFornecedor == 0)
                {
                    return BadRequest("É necessário selecionar um posto de combustível");
                }

                // Verificar se está em percurso com este veículo
                var percursoAtual = _percursoService.ObterPercursosAtualDoMotorista((int)idPessoa);
                if (percursoAtual == null || percursoAtual.IdVeiculo != model.IdVeiculo)
                {
                    return BadRequest("Você não está em um percurso ativo com este veículo");
                }

                // Validar se o odômetro informado não é menor que o atual
                int kmAtual = (int)model.KmAtual;
                if (veiculo.Odometro >= kmAtual)
                {
                    return BadRequest($"O odômetro informado ({kmAtual} km) não pode ser menor ou igual ao odômetro atual do veículo ({veiculo.Odometro} km)");
                }

                // Criar o abastecimento
                var abastecimento = new Abastecimento
                {
                    IdVeiculo = model.IdVeiculo,
                    IdFornecedor = model.IdFornecedor,
                    IdPessoa = idPessoa,
                    IdFrota = veiculo.IdFrota,
                    DataHora = model.Data,
                    Litros = model.Litros,
                    Odometro = kmAtual
                };

                uint idAbastecimento = _abastecimentoService.Create(abastecimento);
                abastecimento.Id = idAbastecimento;
                _veiculoService.AtualizarOdometroVeiculo(model.IdVeiculo, kmAtual);

                return Ok(new
                {
                    Message = "Abastecimento registrado com sucesso",
                    IdAbastecimento = idAbastecimento,
                    Abastecimento = abastecimento
                });
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao registrar abastecimento: {ex.Message}");
            }
        }
    }
}
