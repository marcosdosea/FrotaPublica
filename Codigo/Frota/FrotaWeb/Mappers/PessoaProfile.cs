using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
    public class PessoaProfile : Profile
    {
        public PessoaProfile() 
        {
            CreateMap<PessoaViewModel, Pessoa>().ReverseMap();
        }
    }
}
