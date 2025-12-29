using Core.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{
    [Authorize]
    public class AlertaValidadeController : Controller
    {
        private readonly IValidadePecaInsumoService validadeService;

        public AlertaValidadeController(IValidadePecaInsumoService validadeService)
        {
            this.validadeService = validadeService;
        }

        // GET: AlertaValidade/Veiculo/5
        [HttpGet]
        public IActionResult Veiculo(uint id)
        {
            var alertas = validadeService.ObterAlertasVeiculo(id);
            return Json(alertas);
        }

        // GET: AlertaValidade/Frota
        [HttpGet]
        public IActionResult Frota()
        {
            uint.TryParse(User.Claims?.FirstOrDefault(claim => claim.Type == "FrotaId")?.Value, out uint idFrota);
            if (idFrota == 0)
            {
                return Json(new List<AlertaValidade>());
            }
            
            var alertas = validadeService.ObterAlertasFrota(idFrota);
            return Json(alertas);
        }

        // GET: AlertaValidade/Unidade/5
        [HttpGet]
        public IActionResult Unidade(uint id)
        {
            var alertas = validadeService.ObterAlertasUnidadeAdministrativa(id);
            return Json(alertas);
        }
    }
}

