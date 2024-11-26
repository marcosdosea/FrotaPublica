using AutoMapper;
using Core.DTO;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
    public class VeiculoPecaInsumoProfile : Profile
    {
        public VeiculoPecaInsumoProfile()
        {
            CreateMap<VeiculoPecaInsumoViewModel, Veiculopecainsumo>().ReverseMap();
        }
    }
}
