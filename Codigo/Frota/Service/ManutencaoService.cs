using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service
{
    /// <summary>
    /// Manter dados de marcas das peças e insumos no banco de dados
    /// </summary>
    public class ManutencaoService : IManutencaoService
    {
        private readonly FrotaContext _context;

        public ManutencaoService(FrotaContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Criar registro de Manutencao no banco
        /// </summary>
        /// <param name="manutencao">Instância de Manutencao</param>
        /// <returns>Id da Manutencao</returns>
        public uint Create(Manutencao manutencao)
        {
            _context.Add(manutencao);
            _context.SaveChanges();
            return manutencao.Id;
        }

        /// <summary>
        /// Excluir Manutencao da base de dados
        /// </summary>
        /// <param name="id">Id do Manutencao</param>
        public void Delete(uint id)
        {
            var entity = _context.Manutencaos.Find(id);
            if (entity != null)
            {
                _context.Remove(entity);
                _context.SaveChanges();
            }
        }

        /// <summary>
        /// Editar dados do Manutencao na base de dados
        /// </summary>
        /// <param name="manutencao">Instância de Manutencao</param>
        public void Edit(Manutencao manutencao)
        {
            _context.Update(manutencao);
            _context.SaveChanges();
        }

        /// <summary>
        /// Obter dados de um Manutencao
        /// </summary>
        /// <param name="id">Id do Manutencao</param>
        /// <returns>Instância de Manutencao ou null, caso não exista</returns>
        public Manutencao? Get(uint id)
        {
            return _context.Manutencaos.Find(id);
        }

        /// <summary>
        /// Obter todos os Manutencao da base de dados
        /// </summary>
        /// <returns>Lista de todos os Manutencao</returns>
        public IEnumerable<Manutencao> GetAll()
        {
            return _context.Manutencaos.AsNoTracking();
        }
    }
}
