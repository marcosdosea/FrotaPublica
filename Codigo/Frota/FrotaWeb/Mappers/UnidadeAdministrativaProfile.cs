using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
	public class UnidadeAdministrativaProfile : Profile
	{
		public UnidadeAdministrativaProfile()
		{
			CreateMap<UnidadeAdministrativaViewModel, Unidadeadministrativa>().ReverseMap();
		}
	}
}
