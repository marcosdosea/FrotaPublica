using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
	public class ManutencaoPecaInsumoProfile : Profile
	{
		public ManutencaoPecaInsumoProfile()
		{
			CreateMap<ManutencaoPecaInsumoViewModel, Manutencaopecainsumo>().ReverseMap();
		}
	}
}
