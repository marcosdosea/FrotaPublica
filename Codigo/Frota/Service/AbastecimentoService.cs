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
    public class AbastecimentoService : IAbastecimentoService
    {
        private readonly FrotaContext context;

        public AbastecimentoService(FrotaContext context)
        {
            this.context = context;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="abastecimento"></param>
        /// <returns></returns>
        public uint Create(Abastecimento abastecimento)
        {
            context.Add(abastecimento);
            context.SaveChanges();
            return abastecimento.Id;
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="idAbastecimento"></param>
        public void Delete(uint idAbastecimento)
        {
            var abastecimento = context.Abastecimentos.Find(idAbastecimento);
            context.Remove(idAbastecimento);
            context.SaveChanges();
        }

        public void Edit(Abastecimento abastecimento)
        {
            context.Update(abastecimento);
            context.SaveChanges();

        }

        public Abastecimento Get(uint idAbastecimento)
        {
            return context.Abastecimentos.Find(idAbastecimento);
        }

        public IEnumerable<Abastecimento> GetAll()
        {
            return context.Abastecimentos.AsNoTracking();
        }
    }
}
