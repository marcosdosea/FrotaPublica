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
	public class PessoaService : IPessoaService
    {
        private readonly FrotaContext context;
        private readonly IFrotaService frotaService;

        public PessoaService(FrotaContext context, IFrotaService frotaService)
        {
            this.context = context;
            this.frotaService = frotaService;
        }
        /// <summary>
        /// Cadastra uma nova pessoa
        /// </summary>
        /// <param name="pessoa"></param>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        public uint Create(Pessoa pessoa)
        {
            context.Add(pessoa);
            context.SaveChanges();
            return pessoa.Id;
        }
        /// <summary>
        /// Exclui uma pessoa na base de dados
        /// </summary>
        /// <param name="idPessoa"></param>
        /// <exception cref="NotImplementedException"></exception>
        public void Delete(uint idPessoa)
        {
            var pessoa = context.Pessoas.Find(idPessoa);
            context.Remove(pessoa);
            context.SaveChanges();
        }
        /// <summary>
        /// Edita uma pessoa na base de dados
        /// </summary>
        /// <param name="pessoa"></param>
        /// <exception cref="NotImplementedException"></exception>
        public void Edit(Pessoa pessoa)
        {
            context.Update(pessoa);
            context.SaveChanges();
        }
        /// <summary>
        /// Busca uma pessoa cadastrada
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        public Pessoa Get(uint idPessoa)
        {
            return context.Pessoas.Find(idPessoa);
            
        }

        /// <summary>
        /// Busca todas as pessoas cadastradas
        /// </summary>
        /// <returns></returns>
        public IEnumerable<Pessoa> GetAll()
        {
            return context.Pessoas.AsNoTracking();
        }

        public IEnumerable<Pessoa> GetPaged(int page, int lenght)
        {
            uint idFrota = frotaService.GetFrotaByUser();

            return context.Pessoas
                          .Where(v => v.IdFrota == idFrota)
                          .AsNoTracking()
                          .Skip(page * lenght)
                          .Take(lenght);
        }
    }
}
