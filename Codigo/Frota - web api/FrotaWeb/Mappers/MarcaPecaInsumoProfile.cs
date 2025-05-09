using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
    public class MarcaPecaInsumoProfile : Profile
    {
        public MarcaPecaInsumoProfile()
        {
            CreateMap<MarcaPecaInsumoViewModel, Marcapecainsumo>().ReverseMap();
        }
    }
}
