using Core;
using Core.DTO;
using Core.Service;
using Microsoft.EntityFrameworkCore;
using System.Data;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace Service
{
    public class VeiculoService : IVeiculoService
    {
        private readonly FrotaContext context;
        private readonly IHttpContextAccessor httpContextAccessor;

        public VeiculoService(FrotaContext context, IHttpContextAccessor httpContextAccessor)
        {
            this.context = context;
            this.httpContextAccessor = httpContextAccessor;
        }

        /// <summary>
        /// Adiciona novo veículo na base de dados
        /// </summary>
        /// <param name="veiculo"></param>
        /// <returns></returns>
        public uint Create(Veiculo veiculo)
        {
            context.Add(veiculo);
            context.SaveChanges();
            return veiculo.Id;
        }

        /// <summary>
        /// Exclui um veículo da base de dados
        /// </summary>
        /// <param name="idVeiculo"></param>
        public void Delete(uint idVeiculo)
        {
            var veiculo = context.Veiculos.Find(idVeiculo);
            if (veiculo != null)
            {
                context.Remove(veiculo);
                context.SaveChanges();
            }
        }

        /// <summary>
        /// Altera os dados da veiculo na base de dados
        /// </summary>
        /// <param name="veiculo"></param>
        public void Edit(Veiculo veiculo)
        {
            context.Update(veiculo);
            context.SaveChanges();
        }

        /// <summary>
        /// Obter um veículo pelo id
        /// </summary>
        /// <param name="idVeiculo"></param>
        /// <returns></returns>
        public Veiculo? Get(uint idVeiculo)
        {
            return context.Veiculos.Find(idVeiculo);
        }

        /// <summary>
        /// Obter a lista de veiculo cadastradas
        /// </summary>
        /// <returns></returns>
        public IEnumerable<Veiculo> GetAll()
        {
            var cpf = httpContextAccessor.HttpContext?.User?.Identity?.Name;

            if (string.IsNullOrEmpty(cpf))
                throw new UnauthorizedAccessException("Usuário não autenticado.");

            var idFrota = context.Pessoas
                                 .AsNoTracking()
                                 .Where(p => p.Cpf == cpf)
                                 .Select(p => p.IdFrota)
                                 .FirstOrDefault();

            if (idFrota == 0)
                throw new InvalidOperationException("Frota não encontrada para o usuário autenticado.");

            return context.Veiculos
                          .AsNoTracking()
                          .Where(v => v.IdFrota == idFrota)
                          .ToList();
        }

        public IEnumerable<VeiculoDTO> GetVeiculoDTO()
        {
            var veiculoDTO = from veiculo in context.Veiculos
                             join modelo in context.Modeloveiculos
                             on veiculo.IdModeloVeiculo equals modelo.Id
                             orderby veiculo.Id
                             select new VeiculoDTO
                             {
                                 Id = veiculo.Id,
                                 Modelo = modelo.Nome,
                                 Cor = veiculo.Cor,
                                 Placa = veiculo.Placa,
                                 Ano = veiculo.Ano
                             };
            return veiculoDTO.ToList();
        }
	}
}

