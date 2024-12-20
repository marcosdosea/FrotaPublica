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
    public class MarcaPecaInsumoController : ControllerBase
    {
        private readonly IMarcaPecaInsumoService _marcaPecaInsumoService;
        private readonly IMapper _mapper;

        public MarcaPecaInsumoController(IMarcaPecaInsumoService marcaPecaInsumoService, IMapper mapper)
        {
            _marcaPecaInsumoService = marcaPecaInsumoService;
            _mapper = mapper;
        }

        // GET: api/<MarcaPecaInsumoController>
        [HttpGet]
        public ActionResult Get()
        {
            var lista = _marcaPecaInsumoService.GetAll();
            if (lista == null)
                return NotFound();

            return Ok(lista);
        }

        // GET api/<MarcaPecaInsumoController>/5
        [HttpGet("{id}")]
        public ActionResult Get(uint id)
        {
            Marcapecainsumo? obj = _marcaPecaInsumoService.Get(id);
            if (obj  == null)
                return NotFound();

            return Ok(obj);
        }

        // POST api/<MarcaPecaInsumoController>
        [HttpPost]
        public ActionResult Post([FromBody] MarcaPecaInsumoViewModel model)
        {
            if (!ModelState.IsValid)
                return BadRequest("Dados inválidos.");

            var obj = _mapper.Map<Marcapecainsumo>(model);
            _marcaPecaInsumoService.Create(obj);

            return Ok();
        }

        // PUT api/<MarcaPecaInsumoController>/5
        [HttpPut("{id}")]
        public ActionResult Put(uint id, [FromBody] MarcaPecaInsumoViewModel model)
        {
            if (!ModelState.IsValid)
                return BadRequest("Dados inválidos.");

            var obj = _mapper.Map<Marcapecainsumo>(model);
            if (obj == null)
                return NotFound();

            _marcaPecaInsumoService.Edit(obj);

            return Ok();
        }

        // DELETE api/<MarcaPecaInsumoController>/5
        [HttpDelete("{id}")]
        public ActionResult Delete(uint id)
        {
            Marcapecainsumo? obj = _marcaPecaInsumoService.Get(id);
            if (obj == null)
                return NotFound();

            _marcaPecaInsumoService.Delete(id);

            return Ok();
        }
    }
}
