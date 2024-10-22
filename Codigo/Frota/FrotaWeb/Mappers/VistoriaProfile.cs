using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
	public class VistoriaProfile : Profile
	{
		public VistoriaProfile()
		{
			CreateMap<VistoriaViewModel, Vistorium>().ReverseMap();
		}
	}
}
