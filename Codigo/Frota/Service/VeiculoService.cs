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
        private readonly IFrotaService frotaService;

        public VeiculoService(FrotaContext context, IFrotaService frotaService)
        {
            this.context = context;
            this.frotaService = frotaService;
        }

        /// <summary>
        /// Adiciona novo veículo na base de dados
        /// </summary>
        /// <param name="veiculo"></param>
        /// <returns></returns>
        public uint Create(Veiculo veiculo, uint idFrota)
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
        public IEnumerable<Veiculo> GetAll(uint idFrota)
        {
            return context.Veiculos
                          .AsNoTracking()
                          .Where(v => v.IdFrota == idFrota).OrderBy(v => v.Id);
        }

        /// <summary>
        /// Obtém uma lista parcial de veículos para realizar a paginação
        /// </summary>
        /// <param name="page"></param>
        /// <param name="lenght"></param>
        /// <returns>Lista de veículos</returns>
        public IEnumerable<Veiculo> GetPaged(int page, int lenght, uint idFrota)
        {
            return context.Veiculos
                          .AsNoTracking()
                          .Where(v => v.IdFrota == idFrota)
                          .Skip(page * lenght)
                          .Take(lenght);
        }


        /// <summary>
        /// Obtém uma listagem simplificada de veículos
        /// </summary>
        /// <returns>Retorna uma listagem de VeiculosDTO</returns>
        public IEnumerable<VeiculoDTO> GetVeiculoDTO(int idFrota)
        {
            var veiculoDTO = from veiculo in context.Veiculos
                             where veiculo.IdFrota == idFrota
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

