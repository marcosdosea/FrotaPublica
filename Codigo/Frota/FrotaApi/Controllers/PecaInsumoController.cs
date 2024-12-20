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
    [Authorize]
    public class PecaInsumoController : ControllerBase
    {

        private readonly IPecaInsumoService _pecaInsumoService;
        private readonly IMapper _mapper;

        public PecaInsumoController(IPecaInsumoService pecaInsumoService, IMapper mapper)
        {
            _pecaInsumoService = pecaInsumoService;
            _mapper = mapper;
        }

        [HttpGet]
        // GET: api/<PecaInsumoController>

        public ActionResult Get()
        {
            var listaPecasInsumos = _pecaInsumoService.GetAll();
            if(listaPecasInsumos == null)
                return NotFound();
            return Ok(listaPecasInsumos);
        }
      

        // GET api/<PecaInsumoController>/5
        [HttpGet("{id}")]
        public ActionResult Get(uint id)
        {
            Pecainsumo peca = _pecaInsumoService.Get(id);
            if(peca == null)
                return NotFound();
            return Ok(peca);
        }

        // POST api/<PecaInsumoController>
        [HttpPost]
        public ActionResult Post([FromBody] PecaInsumoViewModel pecamodel)
        {
            if (!ModelState.IsValid)
                return BadRequest("Dados Invalidos.");
            
                var pecaInsumo = _mapper.Map<Pecainsumo>(pecamodel);
                _pecaInsumoService.Create(pecaInsumo);

            return Ok();
            
        }

        // PUT api/<PecaInsumoController>/5
        [HttpPut("{id}")]
        public ActionResult Put(uint id, [FromBody] PecaInsumoViewModel pecamodel)
        {
            if (!ModelState.IsValid)
                return BadRequest("Dados Invalidos.");

                var pecaInsumo = _mapper.Map<Pecainsumo>(pecamodel);
            if (pecaInsumo == null)
                return NotFound();
                
                _pecaInsumoService.Edit(pecaInsumo);

            return Ok();
            
        }

        // DELETE api/<PecaInsumoController>/5
        [HttpDelete("{id}")]
        public ActionResult Delete(uint id)
        {
            Pecainsumo peca = _pecaInsumoService.Get(id);
            if(peca == null) 
                return NotFound();

            _pecaInsumoService.Delete(id);
            return Ok();
        }
    }
}
