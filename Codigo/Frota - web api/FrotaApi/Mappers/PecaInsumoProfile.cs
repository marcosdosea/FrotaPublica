using AutoMapper;
using Core;
using FrotaApi.Models;

namespace FrotaApi.Mappers
{
    public class PecaInsumoProfile : Profile
    {
        public PecaInsumoProfile()
        {
            CreateMap<PecaInsumoViewModel, Pecainsumo>().ReverseMap();
        }
    }
}
