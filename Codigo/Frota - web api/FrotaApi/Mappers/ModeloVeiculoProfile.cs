using AutoMapper;
using Core;
using FrotaApi.Models;

namespace FrotaApi.Mappers
{
    public class ModeloVeiculoProfile : Profile
    {
        public ModeloVeiculoProfile()
        {
            CreateMap<ModeloVeiculoViewModel, Modeloveiculo>().ReverseMap();
        }
    }
}
