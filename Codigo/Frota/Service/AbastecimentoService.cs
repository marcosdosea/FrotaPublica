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
        private readonly IFrotaService frotaService;
        private readonly IPessoaService pessoaService;

        public AbastecimentoService(FrotaContext context, IFrotaService frotaService, IPessoaService pessoaService)
        {
            this.context = context;
            this.frotaService = frotaService;
            this.pessoaService = pessoaService;
        }

        /// <summary>
        /// Adiciona novo abastecimento na base de dados
        /// </summary>
        /// <param name="abastecimento"></param>
        /// <returns></returns>
        public uint Create(Abastecimento abastecimento, int idFrota)
        {
            abastecimento.IdFrota = (uint)idFrota;
            abastecimento.IdPessoa = pessoaService.GetPessoaIdUser();
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
        /// Altera os dados da veiculo na base de dados
        /// </summary>
        /// <param name="abastecimento"></param>
        public void Edit(Abastecimento abastecimento, int idFrota)
        {
            abastecimento.IdPessoa = pessoaService.GetPessoaIdUser();
            abastecimento.IdFrota = (uint)idFrota;
            context.Update(abastecimento);
            context.SaveChanges();

        }

        /// <summary>
        /// Obter um abastecimento pelo id
        /// </summary>
        /// <param name="idAbastecimento"></param>
        /// <returns></returns>
        public Abastecimento? Get(uint idAbastecimento)
        {
            return context.Abastecimentos.Find(idAbastecimento);
        }

        /// <summary>
        /// Obter a lista de abastecimentos cadastradas
        /// </summary>
        /// <returns></returns>
        public IEnumerable<Abastecimento> GetAll(int idFrota)
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
