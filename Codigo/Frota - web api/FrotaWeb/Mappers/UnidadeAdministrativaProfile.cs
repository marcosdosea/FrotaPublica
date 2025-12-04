using AutoMapper;
using Core;
using Core.DTO;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
	public class UnidadeAdministrativaProfile : Profile
	{
		public UnidadeAdministrativaProfile()
		{
			CreateMap<UnidadeAdministrativaViewModel, Unidadeadministrativa>().ReverseMap();
			CreateMap<UnidadeAdministrativaDTO, UnidadeAdministrativaViewModel>().ReverseMap();
		}
	}
}
