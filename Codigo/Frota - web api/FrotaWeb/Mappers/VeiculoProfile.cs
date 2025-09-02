using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
    public class VeiculoProfile: Profile
    {
        public VeiculoProfile()
        {
            CreateMap<VeiculoViewModel, Veiculo>().ReverseMap();
        }
    }
}

