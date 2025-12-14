using Core;
using Core.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Motorista")]
    public class PercursoController : ControllerBase
    {
        private readonly IPercursoService _percursoService;
        private readonly IPessoaService _pessoaService;
        private readonly IVeiculoService _veiculoService;
        private readonly IRotaService _rotaService;

        public PercursoController(
            IPercursoService percursoService,
            IPessoaService pessoaService,
            IVeiculoService veiculoService,
            IRotaService rotaService)
        {
            _percursoService = percursoService;
            _pessoaService = pessoaService;
            _veiculoService = veiculoService;
            _rotaService = rotaService;
        }

        public class IniciarPercursoModel
        {
            public uint IdVeiculo { get; set; }
            public string LocalPartida { get; set; }
            public string LocalChegada { get; set; }
            public int OdometroInicial { get; set; }
            public string? Motivo { get; set; }
            public float? LatitudePartida { get; set; }
            public float? LongitudePartida { get; set; }
            public float? LatitudeChegada { get; set; }
            public float? LongitudeChegada { get; set; }
        }

        public class FinalizarPercursoModel
        {
            public uint IdPercurso { get; set; }
            public int OdometroFinal { get; set; }
        }

        [HttpPost("iniciar")]
        public ActionResult<Percurso> IniciarPercurso([FromBody] IniciarPercursoModel model)
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

                // Verificar se o motorista já tem um percurso em andamento
                var percursoAtual = _percursoService.ObterPercursosAtualDoMotorista((int)idPessoa);
                if (percursoAtual != null)
                {
                    return Ok(new
                    {
                        message = "Motorista já possui um percurso em andamento",
                        emPercurso = true,
                        percurso = new
                        {
                            id = percursoAtual.Id,
                            idPessoa = percursoAtual.IdPessoa,
                            idVeiculo = percursoAtual.IdVeiculo,
                            dataHoraSaida = percursoAtual.DataHoraSaida,
                            dataHoraRetorno = percursoAtual.DataHoraRetorno,
                            localPartida = percursoAtual.LocalPartida,
                            latitudePartida = percursoAtual.LatitudePartida,
                            longitudePartida = percursoAtual.LongitudePartida,
                            localChegada = percursoAtual.LocalChegada,
                            latitudeChegada = percursoAtual.LatitudeChegada,
                            longitudeChegada = percursoAtual.LongitudeChegada,
                            odometroInicial = percursoAtual.OdometroInicial,
                            odometroFinal = percursoAtual.OdometroFinal,
                            motivo = percursoAtual.Motivo
                        }
                    });
                }

                // Criar o percurso
                var percurso = new Percurso
                {
                    IdPessoa = idPessoa,
                    IdVeiculo = model.IdVeiculo,
                    DataHoraSaida = DateTime.Now,
                    DataHoraRetorno = DateTime.MinValue, 
                    LocalPartida = model.LocalPartida,
                    LatitudePartida = model.LatitudePartida,
                    LongitudePartida = model.LongitudePartida,
                    LocalChegada = model.LocalChegada,
                    LatitudeChegada = model.LatitudeChegada,
                    LongitudeChegada = model.LongitudeChegada,
                    OdometroInicial = model.OdometroInicial,
                    OdometroFinal = 0, 
                    Motivo = model.Motivo
                };

                uint idPercurso = _percursoService.Create(percurso);
                percurso.Id = idPercurso;

                return Ok(new
                {
                    message = "Percurso iniciado com sucesso",
                    emPercurso = false,
                    idPercurso = idPercurso,
                    percurso = new
                    {
                        id = percurso.Id,
                        idPessoa = percurso.IdPessoa,
                        idVeiculo = percurso.IdVeiculo,
                        dataHoraSaida = percurso.DataHoraSaida,
                        dataHoraRetorno = percurso.DataHoraRetorno,
                        localPartida = percurso.LocalPartida,
                        latitudePartida = percurso.LatitudePartida,
                        longitudePartida = percurso.LongitudePartida,
                        localChegada = percurso.LocalChegada,
                        latitudeChegada = percurso.LatitudeChegada,
                        longitudeChegada = percurso.LongitudeChegada,
                        odometroInicial = percurso.OdometroInicial,
                        odometroFinal = percurso.OdometroFinal,
                        motivo = percurso.Motivo
                    }
                });
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao iniciar percurso: {ex.Message}");
            }
        }

        [HttpPost("finalizar")]
        public ActionResult FinalizarPercurso([FromBody] FinalizarPercursoModel model)
        {
            try
            {
                // Obter a pessoa (motorista) logada
                uint idPessoa = (uint)_pessoaService.GetPessoaIdUser();

                // Verificar se o percurso existe
                var percurso = _percursoService.Get(model.IdPercurso);
                if (percurso == null)
                {
                    return NotFound("Percurso não encontrado");
                }

                // Verificar se o percurso pertence ao motorista
                if (percurso.IdPessoa != idPessoa)
                {
                    return BadRequest("Você não tem permissão para finalizar este percurso");
                }

                // Verificar se o percurso já foi finalizado
                if (percurso.DataHoraRetorno != DateTime.MinValue)
                {
                    return BadRequest("Este percurso já foi finalizado");
                }

                // Atualizar o odômetro do veículo
                if(model.OdometroFinal < _veiculoService.Get(percurso.IdVeiculo).Odometro)
                {
                    return BadRequest("Odometro final menor que o odometro atual do veiculo");
                }
                _veiculoService.AtualizarOdometroVeiculo(percurso.IdVeiculo, model.OdometroFinal);
                _veiculoService.VeiculoSendoUsado(percurso.IdVeiculo, false);

                // Finalizar o percurso
                percurso.DataHoraRetorno = DateTime.Now;
                percurso.OdometroFinal = model.OdometroFinal;
                
                _percursoService.Edit(percurso);

                // Remover rotas associadas ao percurso
                _rotaService.RemoverRotasPorPercurso(model.IdPercurso);

                return Ok(new
                {
                    message = "Percurso finalizado com sucesso",
                    idPercurso = model.IdPercurso
                });
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao finalizar percurso: {ex.Message}");
            }
        }

        [HttpGet("atual")]
        public ActionResult<Percurso> GetPercursoAtual()
        {
            try
            {
                // Obter a pessoa (motorista) logada
                uint idPessoa = (uint)_pessoaService.GetPessoaIdUser();

                // Obter o percurso atual do motorista
                var percurso = _percursoService.ObterPercursosAtualDoMotorista((int)idPessoa);
                if (percurso == null)
                {
                    return Ok(new
                    {
                        Message = "Não há percurso em andamento",
                        EmPercurso = false
                    });
                }

                return Ok(new
                {
                    Message = "Percurso em andamento",
                    EmPercurso = true,
                    Percurso = percurso
                });
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao buscar percurso atual: {ex.Message}");
            }
        }

        [HttpGet("{id}")]
        public ActionResult<Percurso> GetPercurso(uint id)
        {
            try
            {
                var percurso = _percursoService.Get(id);
                if (percurso == null)
                {
                    return NotFound("Percurso não encontrado");
                }

                return Ok(percurso);
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao buscar percurso: {ex.Message}");
            }
        }
    }
} 