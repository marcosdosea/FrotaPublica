using Core;
using Core.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class RotaController : ControllerBase
    {
        private readonly IRotaService _rotaService;
        private readonly IPercursoService _percursoService;

        public RotaController(IRotaService rotaService, IPercursoService percursoService)
        {
            _rotaService = rotaService;
            _percursoService = percursoService;
        }

        /// <summary>
        /// Obtém a rota de um percurso. Se não existir no banco, busca no Google Maps e salva.
        /// </summary>
        [HttpGet("percurso/{idPercurso}")]
        public async Task<ActionResult> ObterRotaPorPercurso(uint idPercurso)
        {
            try
            {
                // Obter o percurso
                var percurso = _percursoService.Get(idPercurso);
                if (percurso == null)
                {
                    return NotFound("Percurso não encontrado");
                }

                // Verificar se o percurso tem coordenadas válidas
                if (!percurso.LatitudePartida.HasValue || !percurso.LongitudePartida.HasValue ||
                    !percurso.LatitudeChegada.HasValue || !percurso.LongitudeChegada.HasValue)
                {
                    return BadRequest("Percurso não possui coordenadas válidas");
                }

                // Obter a rota
                var routeJson = await _rotaService.ObterRotaAsync(
                    idPercurso,
                    percurso.LatitudePartida.Value,
                    percurso.LongitudePartida.Value,
                    percurso.LatitudeChegada.Value,
                    percurso.LongitudeChegada.Value
                );

                return Content(routeJson, "application/json");
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao obter rota: {ex.Message}");
            }
        }
    }
}

