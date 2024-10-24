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
    public class FrotaService : IFrotaService
    {
        private readonly FrotaContext context;

        public FrotaService(FrotaContext context)
        {
            this.context = context;
        }
        /// <summary>
        /// Adionar nova frota na base de dados
        /// </summary>
        /// <param name="frota"></param>
        /// <returns></returns>
        public uint Create(Frota frota)
        {
           context.Add(frota);
           context.SaveChanges();
           return frota.Id;
        }

        /// <summary>
        /// Excluir uma frota da base de dados
        /// </summary>
        /// <param name="idFrota"></param>
        /// <returns>retorna verdadeiro se o registro for removido</returns>
        public bool Delete(uint idFrota)
        {
            var frota = context.Frota.Find(idFrota);
            if(frota != null)
            {
                context.Remove(frota);
                context.SaveChanges();
                return true;
            }
            return false;
        }


        /// <summary>
        /// Alterar os dados da frota na base de dados
        /// </summary>
        /// <param name="frota"></param>
        public void Edit(Frota frota)
        {
            context.Update(frota);
            context.SaveChanges();
        }

        /// <summary>
        /// Obter pelo id da frota
        /// </summary>
        /// <param name="idFrota"></param>
        /// <returns>retorna o objeto ou um valor nulo</returns>
        public Frota? Get(uint idFrota)
        {
             return context.Frota.Find(idFrota);
   
        }
        /// <summary>
        /// Obter a lista de frota cadastradas
        /// </summary>
        /// <returns></returns>
        public IEnumerable<Frota> GetAll()
        {
            return context.Frota.AsNoTracking();
        }
    }
}
