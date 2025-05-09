using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers;

public class SolicitacaoManutencaoProfile : Profile
{
    public SolicitacaoManutencaoProfile()
    {
        CreateMap<SolicitacaoManutencaoViewModel, Solicitacaomanutencao>().ReverseMap();
    }
}

