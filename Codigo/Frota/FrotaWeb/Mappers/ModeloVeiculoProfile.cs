using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
    public class ModeloVeiculoProfile : Profile
    {
        public ModeloVeiculoProfile()
        {
            CreateMap<ModeloVeiculoViewModel, Modeloveiculo>().ReverseMap();
        }
    }
}
