using Core;
using Core.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Service
{
    public class VeiculoPecaInsumoService : IVeiculoPecaInsumoService
    {
        private readonly FrotaContext context;

        public VeiculoPecaInsumoService(FrotaContext context)
        {
            this.context = context;
        }

        public void Create(Veiculopecainsumo veiculoPecaInsumo)
        {
            context.Add(veiculoPecaInsumo);
            context.SaveChanges();
        }

        public void Delete(Veiculopecainsumo veiculopecainsumo)
        {
            context.Remove(veiculopecainsumo);
            context.SaveChanges();
        }

        public void Edit(Veiculopecainsumo veiculoPecaInsumo)
        {
            context.Update(veiculoPecaInsumo);
            context.SaveChanges();
        }

        public Veiculopecainsumo? Get(uint IdVeiculo, uint IdPecaInsumo)
        {
            return context.Veiculopecainsumos.Find(IdVeiculo, IdPecaInsumo);
        }

        public IEnumerable<Veiculopecainsumo> GetAll()
        {
            return context.Veiculopecainsumos;
        }
    }
}
