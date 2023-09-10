using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers;

public class SolicitacaomanutencaoProfile : Profile
{
    public SolicitacaomanutencaoProfile()
    {
        CreateMap<SolicitacaomanutencaoViewModel, Solicitacaomanutencao>().ReverseMap();
    }
}

