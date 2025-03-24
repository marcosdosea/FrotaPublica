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
    public class CadastroDeMarcasDeVeículosController : ControllerBase
    {
        private readonly IMarcaVeiculoService _marcaVeiculoService;
        private readonly IMapper _mapper;

        public CadastroDeMarcasDeVeículosController(IMarcaVeiculoService marcaVeiculoService, IMapper mapper)
        {
            _marcaVeiculoService = marcaVeiculoService;
            _mapper = mapper;
        }

        
    }
}
