using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Mvc;

namespace FrotaApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SolicitacaoManutencaoController : ControllerBase
    {
        private readonly IMapper _mapper;
        private readonly ISolicitacaomanutencaoService _service;

        public SolicitacaoManutencaoController(ISolicitacaomanutencaoService service, IMapper mapper)
        {
            _mapper = mapper;
            _service = service;
        }

        [HttpGet]
        public ActionResult Get()
        {
            var solicitacoes = _service.GetAll();
            if (solicitacoes == null)
                return NotFound();

            return Ok(solicitacoes);
        }

        [HttpGet("{id}")]
        public ActionResult Get(uint id)
        {
            Solicitacaomanutencao? solicitacao = _service.Get(id);
            if(solicitacao == null)
                return NotFound();

            return Ok(solicitacao);
        }

        [HttpPost]
        public ActionResult Post([FromBody] SolicitacaomanutencaoViewModel solicitacaoModel)
        {
            if (!ModelState.IsValid)
                return BadRequest("Dados Inválidos.");

                var solicitacao = _mapper.Map<Solicitacaomanutencao>(solicitacaoModel);
                _service.Create(solicitacao);

            return Ok();
        }

        [HttpPut("{id}")]
        public ActionResult Put(uint id, [FromBody] SolicitacaomanutencaoViewModel solicitacaoModel)
        {
            if (!ModelState.IsValid)
                return BadRequest("Dados Inválidos.");

            var solicitacao = _mapper.Map<Solicitacaomanutencao>(solicitacaoModel);
            if (solicitacao == null)
                return NotFound();

            _service.Edit(solicitacao);
            return Ok();
        }

        [HttpDelete("{id}")]
        public ActionResult Delete(uint id)
        {
            Solicitacaomanutencao? solicitacao = _service.Get(id);
            if(solicitacao == null)
                return NotFound();

            _service.Delete(id);
            return Ok();
        }
    }
}
