using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace FrotaApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
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
        public ActionResult<List<PecaInsumoViewModel>> Get()
        {
            var listaPecasInsumos = _pecaInsumoService.GetAll();
            var listaPecasInsumosModel = _mapper.Map<List<PecaInsumoViewModel>>(listaPecasInsumos);
            return listaPecasInsumosModel;
        }
      

        // GET api/<PecaInsumoController>/5
        [HttpGet("{id}")]
        public ActionResult <PecaInsumoViewModel> Get(uint id)
        {
            Pecainsumo peca = _pecaInsumoService.Get(id);
            PecaInsumoViewModel pecamodel = _mapper.Map<PecaInsumoViewModel>(peca);
            return pecamodel;
        }

        // POST api/<PecaInsumoController>
        [HttpPost]
        public void Post([FromBody] string value)
        {
        }

        // PUT api/<PecaInsumoController>/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody] string value)
        {
        }

        // DELETE api/<PecaInsumoController>/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}
