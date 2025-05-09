using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service
{
    /// <summary>
    /// Manter dados de manuten��es de ve�culos no banco de dados
    /// </summary>
    public class ManutencaoService : IManutencaoService
    {
        private readonly FrotaContext context;

        public ManutencaoService(FrotaContext context)
        {
            this.context = context;
        }

        /// <summary>
        /// Criar registro de manuten��o no banco
        /// </summary>
        /// <param name="manutencao">Inst�ncia de manuten��o</param>
        /// <returns>Id da manuten��o</returns>
        public uint Create(Manutencao manutencao)
        {
            context.Add(manutencao);
            context.SaveChanges();
            return manutencao.Id;
        }

        /// <summary>
        /// Excluir manutenc�o da base de dados
        /// </summary>
        /// <param name="id">Id da manuten��o</param>
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
                    throw new ServiceException("Erro ao excluir manuten��o no banco de dados.", exception);
                }
            }
        }

        /// <summary>
        /// Editar dados da manuten��o na base de dados
        /// </summary>
        /// <param name="manutencao">Inst�ncia de manuten��o</param>
        public void Edit(Manutencao manutencao)
        {
            context.Update(manutencao);
            context.SaveChanges();
        }

        /// <summary>
        /// Obter dados de uma manuten��o
        /// </summary>
        /// <param name="id">Id da manuten��o</param>
        /// <returns>Inst�ncia de Manutencao ou null, caso n�o exista</returns>
        public Manutencao? Get(uint id)
        {
            return context.Manutencaos.Find(id);
        }

        /// <summary>
        /// Obter todas as manutenc�es da base de dados
        /// </summary>
        /// <returns>Cole��o de objetos Manutencao</returns>
        public IEnumerable<Manutencao> GetAll(uint idFrota)
        {
            return context.Manutencaos
                          .Where(manutencao => manutencao.IdFrota == idFrota)
                          .AsNoTracking();
        }
    }
}
