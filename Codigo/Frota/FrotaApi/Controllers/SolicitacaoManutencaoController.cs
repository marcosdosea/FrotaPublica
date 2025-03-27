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

        
    }
}
