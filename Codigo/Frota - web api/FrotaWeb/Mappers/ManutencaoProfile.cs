using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
    public class ManutencaoProfile : Profile
    {
        public ManutencaoProfile()
        {
            CreateMap<ManutencaoViewModel, Manutencao>().ReverseMap();
        }
    }
}
