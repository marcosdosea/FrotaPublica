using Core;
using Core.DTO;
using Core.Service;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System.Data;

namespace Service
{
    public class VeiculoService : IVeiculoService
    {
        private readonly FrotaContext context;

        public VeiculoService(FrotaContext context)
        {
            this.context = context;
        }

        /// <summary>
        /// Adiciona novo veículo na base de dados
        /// </summary>
        /// <param name="veiculo"></param>
        /// <returns></returns>
        public uint Create(Veiculo veiculo)
        {
            try
            {
                context.Add(veiculo);
                context.SaveChanges();
            }
            catch (Exception exception)
            {
                throw new ServiceException("Erro ao inserir veículo no banco de dados.", exception);
            }
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
                try
                {
                    context.Remove(veiculo);
                    context.SaveChanges();
                }
                catch (Exception exception)
                {
                    throw new ServiceException("Erro ao excluir veículo no banco de dados.", exception);
                }
            }
        }

        /// <summary>
        /// Altera os dados da veiculo na base de dados
        /// </summary>
        /// <param name="veiculo"></param>
        public void Edit(Veiculo veiculo)
        {
            try
            {
                context.Update(veiculo);
                context.SaveChanges();
            }
            catch (Exception exception)
            {
                throw new ServiceException("Erro ao editar veículo no banco de dados.", exception);
            }
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
        /// Obter a Placa de um veículo através do Id
        /// </summary>
        /// <param name="idVeiculo"></param>
        /// <returns></returns>
        public string? GetPlacaVeiculo(uint idVeiculo)
        {
            return context.Veiculos
                          .Where(veiculo => veiculo.Id == idVeiculo)
                          .Select(veiculo => veiculo.Placa)
                          .FirstOrDefault();
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
        /// Obtém uma lista parcial de veículos disponíveis para realizar a paginação
        /// </summary>
        /// <param name="page"></param>
        /// <param name="lenght"></param>
        /// <param name="idFrota"></param>
        /// <param name="unidadeAdministrativa"></param>
        /// <returns>Lista de Veículos</returns>
        public PagedResult<Veiculo> GetVeiculosDisponiveisUnidadeAdministrativaPaged(int page, int length, uint idFrota, uint unidadeAdministrativa, string placa)
        {
            var query = context.Veiculos
                               .AsNoTracking()
                               .Where(v => v.IdFrota == idFrota &&
                                           v.IdUnidadeAdministrativa == unidadeAdministrativa &&
                                           v.Status == "D");

            if (!string.IsNullOrWhiteSpace(placa))
            {
                query = query.Where(v => v.Placa.ToUpper().Contains(placa.ToUpper()));
            }

            int totalCount = query.Count();

            var items = query.Skip(page * length)
                             .Take(length)
                             .ToList();

            return new PagedResult<Veiculo>
            {
                Items = items,
                TotalCount = totalCount
            };
        }

        /// <summary>
        /// Obtem todos os veículos de determinada frota e unidade administrativa, podendo ser filtrado por placa
        /// </summary>
        /// <param name="idFrota"></param>
        /// <param name="unidadeAdministrativa"></param>
        /// <param name="placa"></param>
        /// <returns></returns>
        public List<Veiculo>? GetAllFilterByPlaca(uint idFrota, uint unidadeAdministrativa, string placa)
        {
            var query = context.Veiculos
                               .AsNoTracking()
                               .Where(v => v.IdFrota == idFrota &&
                                           v.IdUnidadeAdministrativa == unidadeAdministrativa &&
                                           v.Status == "D");

            if (!string.IsNullOrWhiteSpace(placa))
            {
                query = query.Where(v => v.Placa.ToUpper().Replace("-","").Replace(" ","").Contains(placa.ToUpper().Replace("-", "").Replace(" ", "")));
            }

            int totalCount = query.Count();

            var items = query.ToList();

            return items;
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

        public bool AtualizarOdometroVeiculo(uint idVeiculo, int novoOdometro)
        {
            var veiculo = context.Veiculos.Find(idVeiculo);
            if(novoOdometro <= veiculo.Odometro)
            {
                return false;
            }
            veiculo.Odometro = novoOdometro;
            Edit(veiculo);
            return true;
        }
    }
}

