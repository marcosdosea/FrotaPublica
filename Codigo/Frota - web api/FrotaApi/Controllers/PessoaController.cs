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
	public class PessoaController : ControllerBase
	{
		private readonly IPessoaService _pessoaService;
		private readonly IMapper _mapper;

		public PessoaController(IPessoaService pessoaService, IMapper mapper)
		{
			_pessoaService = pessoaService;
			_mapper = mapper;
		}

		
	}
}

