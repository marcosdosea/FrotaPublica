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
        private readonly IPessoaService _pessoaService;
        private readonly IMapper _mapper;

        public FornecedorController(IFornecedorService fornecedorService, IPessoaService pessoaService, IMapper mapper)
        {
            _fornecedorService = fornecedorService;
            _pessoaService = pessoaService;
            _mapper = mapper;
        }

        // GET: api/Fornecedor
        [HttpGet]
        public ActionResult<IEnumerable<Fornecedor>> Get()
        {
            try
            {
                // Obter o ID da pessoa do usuário logado
                uint pessoaId = (uint)_pessoaService.GetPessoaIdUser();

                // Obter a pessoa para ter acesso à frota
                var pessoa = _pessoaService.Get(pessoaId);
                if (pessoa == null)
                {
                    return NotFound("Pessoa não encontrada");
                }

                // Obter todos os fornecedores da frota
                var fornecedores = _fornecedorService.GetAll((int)pessoa.IdFrota);
                
                return Ok(fornecedores);
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao obter fornecedores: {ex.Message}");
            }
        }

        // GET: api/Fornecedor/5
        [HttpGet("{id}")]
        public ActionResult<Fornecedor> Get(uint id)
        {
            try
            {
                var fornecedor = _fornecedorService.Get(id);
                if (fornecedor == null)
                {
                    return NotFound("Fornecedor não encontrado");
                }

                return Ok(fornecedor);
            }
            catch (Exception ex)
            {
                return BadRequest($"Erro ao obter fornecedor: {ex.Message}");
            }
        }
    }
}
