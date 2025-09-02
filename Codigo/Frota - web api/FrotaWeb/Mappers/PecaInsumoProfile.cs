using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
    public class PecaInsumoProfile : Profile
    {
        public PecaInsumoProfile()
        {
            CreateMap<PecaInsumoViewModel, Pecainsumo>().ReverseMap();
        }
    }
}
