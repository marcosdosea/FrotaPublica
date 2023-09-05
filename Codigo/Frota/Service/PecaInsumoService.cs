using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
            var peca = _context.Pecainsumos.Find(idPeca);
            _context.Remove(peca);
            _context.SaveChanges();
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

        public IEnumerable<Pecainsumo> GetAll()
        {
            return _context.Pecainsumos.AsNoTracking();
        }
    }
}