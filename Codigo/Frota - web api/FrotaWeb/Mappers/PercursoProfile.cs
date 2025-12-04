using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
	public class PercursoProfile : Profile
	{
		public PercursoProfile()
		{
			CreateMap<Percurso, PercursoViewModel>().ReverseMap();
		}
	}
}
