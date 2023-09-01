using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service
{
    /// <summary>
    /// Manter dados de marcas, peças e insumos no banco de dados
    /// </summary>
    public class MarcaPecaInsumoService : IMarcaPecaInsumoService
    {
        private readonly FrotaContext _context;

        public MarcaPecaInsumoService(FrotaContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Criar registro de Marcapecainsumo no banco
        /// </summary>
        /// <param name="marcapecainsumo">Instância de Marcapecainsumo</param>
        /// <returns>Id do Marcapecainsumo</returns>
        public uint Create(Marcapecainsumo marcapecainsumo)
        {
            _context.Add(marcapecainsumo);
            _context.SaveChanges();
            return marcapecainsumo.Id;
        }

        /// <summary>
        /// Excluir Marcapecainsumo da base de dados
        /// </summary>
        /// <param name="id">Id do Marcapecainsumo</param>
        public void Delete(uint id)
        {
            var entity = _context.Marcapecainsumos.Find(id);
            if (entity != null)
            {
                _context.Remove(entity);
                _context.SaveChanges();
            }
        }

        /// <summary>
        /// Editar dados do Marcapecainsumo na base de dados
        /// </summary>
        /// <param name="marcapecainsumo">Instância de Marcapecainsumo</param>
        public void Edit(Marcapecainsumo marcapecainsumo)
        {
            _context.Update(marcapecainsumo);
            _context.SaveChanges();
        }

        /// <summary>
        /// Obter dados de um Marcapecainsumo
        /// </summary>
        /// <param name="id">Id do Marcapecainsumo</param>
        /// <returns>Instância de Marcapecainsumo ou null, caso não exista</returns>
        public Marcapecainsumo? Get(uint id)
        {
            return _context.Marcapecainsumos.Find(id);
        }

        /// <summary>
        /// Obter todos os Marcapecainsumo da base de dados
        /// </summary>
        /// <returns>Lista de todos os Marcapecainsumo</returns>
        public IEnumerable<Marcapecainsumo> GetAll()
        {
            return _context.Marcapecainsumos.AsNoTracking();
        }
    }
}
