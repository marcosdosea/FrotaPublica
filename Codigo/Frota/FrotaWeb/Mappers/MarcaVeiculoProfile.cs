using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
	public class MarcaVeiculoProfile : Profile
	{
		public MarcaVeiculoProfile()
		{
			CreateMap<MarcaVeiculoViewModel, Marcaveiculo>().ReverseMap();
		}
	}
}
