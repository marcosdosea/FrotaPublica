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
    public class FornecedorService : IFornecedorService
    {
        private readonly FrotaContext context;

        public FornecedorService(FrotaContext context)
        {
            this.context = context;
        }
        /// <summary>
        /// Adionar nova frota na base de dados
        /// </summary>
        /// <param name="frota"></param>
        /// <returns></returns>
        public uint Create(Fornecedor fornecedor, int idFrota)
        {
            fornecedor.IdFrota = (uint)idFrota;
            context.Add(fornecedor);
            context.SaveChanges();
            return fornecedor.Id;
        }

        /// <summary>
        /// Excluir uma frota da base de dados
        /// </summary>
        /// <param name="idFrota"></param>
        public bool Delete(uint idFornecedor)
        {
            var entity = context.Fornecedors.Find(idFornecedor);
            if (entity != null)
            {
                context.Remove(entity);
                context.SaveChanges();
                return true;
            }
            return false;
        }


        /// <summary>
        /// Alterar os dados da frota na base de dados
        /// </summary>
        /// <param name="frota"></param>
        public void Edit(Fornecedor fornecedor, int idFrota)
        {
            fornecedor.IdFrota = (uint)idFrota;
            context.Update(fornecedor);
            context.SaveChanges();
        }

        /// <summary>
        /// Obter pelo id da frota
        /// </summary>
        /// <param name="idFrota"></param>
        /// <returns></returns>
        public Fornecedor Get(uint idFornecedor)
        {
            return context.Fornecedors.Find(idFornecedor);
        }
        /// <summary>
        /// Obter a lista de frota cadastradas
        /// </summary>
        /// <returns></returns>
        public IEnumerable<Fornecedor> GetAll(int idFrota)
        {
            return context.Fornecedors
                          .Where(fornecedor => fornecedor.IdFrota == idFrota)
                          .AsNoTracking();
        }
    }
}