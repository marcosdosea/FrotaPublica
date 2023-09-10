using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
    public class FrotaProfile: Profile
    {
        public FrotaProfile()
        {
            CreateMap<FrotaViewModel, Frota>().ReverseMap();
        }
        
    }
}
