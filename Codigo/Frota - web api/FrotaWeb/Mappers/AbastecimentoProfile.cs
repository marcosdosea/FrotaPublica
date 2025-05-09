using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
    public class AbastecimentoProfile:Profile
    {
        public AbastecimentoProfile() {
            CreateMap<AbastecimentoViewModel, Abastecimento>().ReverseMap();
        }
        
    }
}
