using AutoMapper;
using Core;
using Core.DTO;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
    public class ModeloVeiculoProfile : Profile
    {
        public ModeloVeiculoProfile()
        {
            CreateMap<ModeloVeiculoViewModel, Modeloveiculo>().ReverseMap();
			CreateMap<ModeloVeiculoDTO, ModeloVeiculoViewModel>().ReverseMap();
		}
    }
}
