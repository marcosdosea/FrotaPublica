using AutoMapper;
using Core.Service;
using Core;
using Microsoft.AspNetCore.Mvc;
using FrotaWeb.Models;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace FrotaApi.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	public class PessoaController : ControllerBase
	{
		private readonly IPessoaService _pessoaService;
		private readonly IMapper _mapper;

		public PessoaController(IPessoaService pessoaService, IMapper mapper)
		{
			_pessoaService = pessoaService;
			_mapper = mapper;
		}

		[HttpGet]
		public ActionResult Get()
		{
			var listaPessoa = _pessoaService.GetAll();
			if (listaPessoa == null)
				return NotFound();
			return Ok(listaPessoa);
		}


		[HttpGet("{id}")]
		public ActionResult Get(uint id)
		{
			Pessoa pessoa = _pessoaService.Get(id);
			if (pessoa == null)
				return NotFound();
			return Ok(pessoa);
		}

		[HttpPost]
		public ActionResult Post([FromBody] PessoaViewModel pessoaModel)
		{
			if (!ModelState.IsValid)
				return BadRequest("Dados Inválidos.");

			var pessoa = _mapper.Map<Pessoa>(pessoaModel);
			_pessoaService.Create(pessoa);

			return Ok();

		}

		[HttpPut("{id}")]
		public ActionResult Put(uint id, [FromBody] PessoaViewModel pessoaModel)
		{
			if (!ModelState.IsValid)
				return BadRequest("Dados Inválidos.");

			var pessoa = _mapper.Map<Pessoa>(pessoaModel);
			if (pessoa == null)
				return NotFound();

			_pessoaService.Edit(pessoa);

			return Ok();

		}

		[HttpDelete("{id}")]
		public ActionResult Delete(uint id)
		{
			Pessoa pessoa = _pessoaService.Get(id);
			if (pessoa == null)
				return NotFound();

			_pessoaService.Delete(id);
			return Ok();
		}
	}
}
}
