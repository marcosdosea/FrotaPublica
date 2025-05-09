using AutoMapper;
using Core;
using FrotaApi.Models;

namespace FrotaApi.Mappers;

public class AbastecimentoProfile : Profile
{
    public AbastecimentoProfile()
    {
        CreateMap<AbastecimentoViewModel, Abastecimento>().ReverseMap();
    }

}