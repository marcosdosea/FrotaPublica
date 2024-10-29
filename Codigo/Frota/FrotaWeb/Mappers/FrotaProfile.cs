using AutoMapper;
using Core;
using Core.DTO;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
    public class FrotaProfile: Profile
    {
        public FrotaProfile()
        {
            CreateMap<FrotaViewModel, Frota>().ReverseMap();
			CreateMap<FrotaDTO, FrotaViewModel>().ReverseMap();
		}
        
    }
}
