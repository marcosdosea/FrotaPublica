using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service
{
    /// <summary>
    /// Manter dados de manutenções de veículos no banco de dados
    /// </summary>
    public class ManutencaoService : IManutencaoService
    {
        private readonly FrotaContext context;

        public ManutencaoService(FrotaContext context)
        {
            this.context = context;
        }

        /// <summary>
        /// Criar registro de manutenção no banco
        /// </summary>
        /// <param name="manutencao">Instância de manutenção</param>
        /// <returns>Id da manutenção</returns>
        public uint Create(Manutencao manutencao)
        {
            context.Add(manutencao);
            context.SaveChanges();
            return manutencao.Id;
        }

        /// <summary>
        /// Excluir manutencão da base de dados
        /// </summary>
        /// <param name="id">Id da manutenção</param>
        public void Delete(uint id)
        {
            var entity = context.Manutencaos.Find(id);
            if (entity != null)
            {
                try
                {
                    context.Remove(entity);
                    context.SaveChanges();
                }
                catch (Exception exception)
                {
                    throw new ServiceException("Erro ao excluir manutenção no banco de dados.", exception);
                }
            }
        }

        /// <summary>
        /// Editar dados da manutenção na base de dados
        /// </summary>
        /// <param name="manutencao">Instância de manutenção</param>
        public void Edit(Manutencao manutencao)
        {
            context.Update(manutencao);
            context.SaveChanges();
        }

        /// <summary>
        /// Obter dados de uma manutenção
        /// </summary>
        /// <param name="id">Id da manutenção</param>
        /// <returns>Instância de Manutencao ou null, caso não exista</returns>
        public Manutencao? Get(uint id)
        {
            return context.Manutencaos.Find(id);
        }

        /// <summary>
        /// Obter todas as manutencões da base de dados
        /// </summary>
        /// <returns>Coleção de objetos Manutencao</returns>
        public IEnumerable<Manutencao> GetAll(uint idFrota)
        {
            return context.Manutencaos
                          .Where(manutencao => manutencao.IdFrota == idFrota)
                          .AsNoTracking();
        }
    }
}
