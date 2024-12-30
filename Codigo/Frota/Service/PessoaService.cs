using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;


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
            if (pessoa != null)
            {
                context.Remove(pessoa);
                context.SaveChanges();
            }
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
            uint idFrota = frotaService.GetFrotaByUser();
            return context.Pessoas
                          .AsNoTracking()
                          .Where(f => f.IdFrota == idFrota)
                          .OrderBy(f => f.Id);
        }

        public IEnumerable<Pessoa> GetPaged(int page, int lenght, out int totalResults, string search = null, string filterBy = "Nome")
        {
            uint idFrota = frotaService.GetFrotaByUser();

            var query = context.Pessoas
                               .Where(f => f.IdFrota == idFrota)
                               .AsNoTracking();

            if (!string.IsNullOrEmpty(search))
            {
                switch (filterBy.ToLower())
                {
                    case "cpf":
                        query = query.Where(s => s.Cpf.ToLower().Contains(search.ToLower()));
                        break;
                    case "cidade":
                        query = query.Where(s => s.Cidade.ToLower().Contains(search.ToLower()));
                        break;
                    default:
                        query = query.Where(s => s.Nome.ToLower().Contains(search.ToLower()));
                        break;
                }
            }

            totalResults = query.Count();

            return query.Skip(page * lenght)
                        .Take(lenght);
        }
    }
}
