using AutoMapper;
using Core;
using FrotaWeb.Models;

namespace FrotaWeb.Mappers
{
    public class FornecedorProfile : Profile
    {
        public FornecedorProfile()
        {
            CreateMap<FornecedorViewModel, Fornecedor>().ReverseMap();
        }
    }
}
