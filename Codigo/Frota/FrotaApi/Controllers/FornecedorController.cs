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
    public class FornecedorController : ControllerBase
    {
        private readonly IFornecedorService _fornecedorService;
        private readonly IMapper _mapper;

        public FornecedorController(IFornecedorService fornecedorService, IMapper mapper)
        {
            _fornecedorService = fornecedorService;
            _mapper = mapper;
        }

        [HttpGet]
        public ActionResult Get()
        {
            var listaFornecedor = _fornecedorService.GetAll();
            if (listaFornecedor == null)
                return NotFound();
            return Ok(listaFornecedor);
        }

        [HttpGet("{id}")]
        public ActionResult Get(uint id)
        {
            Fornecedor fornecedor = _fornecedorService.Get(id);
            if (fornecedor == null)
                return NotFound();
            return Ok(fornecedor);
        }

        [HttpPost]
        public ActionResult Post([FromBody] FornecedorViewModel fornecedorModel)
        {
            if (!ModelState.IsValid)
                return BadRequest("Dados Inválidos.");

            var fornecedor = _mapper.Map<Fornecedor>(fornecedorModel);
            _fornecedorService.Create(fornecedor);

            return Ok();
        }

        [HttpPut("{id}")]
        public ActionResult Put(uint id, [FromBody] FornecedorViewModel fornecedorModel)
        {
            if (!ModelState.IsValid)
                return BadRequest("Dados Inválidos.");

            var fornecedor = _mapper.Map<Fornecedor>(fornecedorModel);
            if (fornecedor == null)
                return NotFound();

            _fornecedorService.Edit(fornecedor);

            return Ok();
        }

        [HttpDelete("{id}")]
        public ActionResult Delete(uint id)
        {
            Fornecedor fornecedor = _fornecedorService.Get(id);
            if (fornecedor == null)
                return NotFound();

            _fornecedorService.Delete(id);
            return Ok();
        }
    }
}
