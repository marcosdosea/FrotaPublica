using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service
{
    public class PecaInsumoService : IPecaInsumoService
    {
        private readonly FrotaContext _context;
        public PecaInsumoService(FrotaContext context)
        {
            _context = context;
        }

        public uint Create(Pecainsumo pecainsumo)
        {
            _context.Add(pecainsumo);
            _context.SaveChanges();
            return pecainsumo.Id;
        }

        public void Delete(uint idPeca)
        {
            var pecainsumo = _context.Pecainsumos.Find(idPeca);
            if (pecainsumo != null)
            {
                _context.Remove(pecainsumo);
                _context.SaveChanges();
            }
        }

        public void Edit(Pecainsumo pecainsumo)
        {
            _context.Update(pecainsumo);
            _context.SaveChanges();
        }

        public Pecainsumo? Get(uint idPeca)
        {
            return _context.Pecainsumos.Find(idPeca);
        }

        public IEnumerable<Pecainsumo> GetAll(uint idFrota)
        {
            return _context.Pecainsumos.Where(pecainsumo => pecainsumo.IdFrota == idFrota).AsNoTracking();
        }
    }
}