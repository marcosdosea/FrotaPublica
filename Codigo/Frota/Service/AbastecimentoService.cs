using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

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
        /// Adiciona novo abastecimento na base de dados
        /// </summary>
        /// <param name="abastecimento"></param>
        /// <returns>Id do veículo criado</returns>
        public uint Create(Abastecimento abastecimento)
        {
            context.Add(abastecimento);
            context.SaveChanges();
            return abastecimento.Id;
        }

        /// <summary>
        /// Exclui um abastecimento da base de dados
        /// </summary>
        /// <param name="idAbastecimento"></param>
        public void Delete(uint idAbastecimento)
        {
            var abastecimento = context.Abastecimentos.Find(idAbastecimento);
            if (abastecimento != null)
            {
                context.Remove(abastecimento);
                context.SaveChanges();
            }
        }

        /// <summary>
        /// Altera os dados de um abastecimento na base de dados
        /// </summary>
        /// <param name="abastecimento"></param>
        public void Edit(Abastecimento abastecimento)
        {
            context.Update(abastecimento);
            context.SaveChanges();

        }

        /// <summary>
        /// Obter um abastecimento pelo id
        /// </summary>
        /// <param name="idAbastecimento">O id do abastecimento</param>
        /// <returns>Um objeto que representa o abastecimento</returns>
        public Abastecimento? Get(uint idAbastecimento)
        {
            return context.Abastecimentos.Find(idAbastecimento);
        }

        /// <summary>
        /// Obtém a lista de abastecimentos cadastrados para uma frota específica
        /// </summary>
        /// <param name="idFrota">O id da frota</param>
        /// <returns>Uma coleção de abastecimentos da frota especificada</returns>
        public IEnumerable<Abastecimento> GetAll(uint idFrota)
        {
            return context.Abastecimentos.Where(abastecimento => abastecimento.IdFrota == idFrota).AsNoTracking();
        }

        public IEnumerable<Abastecimento> GetPaged(int page, int lenght, int idFrota)
        {
            return context.Abastecimentos
                          .Where(abastecimento => abastecimento.IdFrota == idFrota)
                          .AsNoTracking()
                          .Skip(page * lenght)
                          .Take(lenght);
        }
    }
}
