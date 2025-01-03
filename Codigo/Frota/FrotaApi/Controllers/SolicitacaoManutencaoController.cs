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
    public class SolicitacaoManutencaoController : ControllerBase
    {
        private readonly IMapper _mapper;
        private readonly ISolicitacaoManutencaoService _service;

        SolicitacaoManutencaoController(ISolicitacaoManutencaoService service, IMapper mapper)
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
            var solicitacao = _service.Get(id);
            if(solicitacao == null)
                return NotFound();

            return Ok(solicitacao);
        }

        [HttpPost]
        public ActionResult Post([FromBody] SolicitacaoManutencaoViewModel solicitacaoModel)
        {
            if (!ModelState.IsValid)
                return BadRequest("Dados Inválidos.");

                var solicitacao = _mapper.Map<Solicitacaomanutencao>(solicitacaoModel);
                _service.Create(solicitacao);

            return Ok();
        }

        [HttpPut("{id}")]
        public ActionResult Put(uint id, [FromBody] SolicitacaoManutencaoViewModel solicitacaoModel)
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
            var solicitacao = _service.Get(id);
            if(solicitacao == null)
                return NotFound();

            _service.Delete(id);
            return Ok();
        }
    }
}
