using Core;
using Core.Service;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;


namespace Service
{
    public class PessoaService : IPessoaService
    {
        private readonly FrotaContext context;
        private readonly IHttpContextAccessor httpContextAccessor;

        public PessoaService(FrotaContext context, IHttpContextAccessor httpContextAccessor)
        {
            this.context = context;
            this.httpContextAccessor = httpContextAccessor;
        }

        /// <summary>
        /// Cadastra uma nova pessoa
        /// </summary>
        /// <param name="pessoa"></param>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        public uint Create(Pessoa pessoa, int idFrota)
        {
            pessoa.IdFrota = (uint)idFrota;
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
        public void Edit(Pessoa pessoa, int idFrota)
        {
            pessoa.IdFrota = (uint)idFrota;
            context.Update(pessoa);
            context.SaveChanges();
        }

        /// <summary>
        /// Busca uma pessoa cadastrada
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        public Pessoa? Get(uint idPessoa)
        {
            return context.Pessoas.Find(idPessoa);
        }

        /// <summary>
        /// Busca todas as pessoas cadastradas
        /// </summary>
        /// <returns></returns>
        public IEnumerable<Pessoa> GetAll(int idFrota)
        {
            return context.Pessoas
                          .Where(f => f.IdFrota == idFrota)
                          .AsNoTracking();
        }

        public uint GetPessoaIdUser()
        {
            var cpf = httpContextAccessor.HttpContext?.User?.Identity?.Name;

            if (string.IsNullOrEmpty(cpf))
                throw new UnauthorizedAccessException("Usuário não autenticado.");

            var idPessoa = context.Pessoas
                                 .AsNoTracking()
                                 .Where(p => p.Cpf == cpf)
                                 .Select(p => p.Id)
                                 .FirstOrDefault();

            if (idPessoa == 0)
                throw new InvalidOperationException("Pessoa não encontrada para o usuário autenticado.");
            return idPessoa;
        }

        public IEnumerable<Pessoa> GetPaged(int idFrota, int page, int lenght, out int totalResults, string? search = null, string filterBy = "Nome")
        {
            var query = context.Pessoas
                               .Where(f => f.IdFrota == idFrota)
                               .AsNoTracking();

            if (!string.IsNullOrEmpty(search))
            {
                string searchLower = search.ToLower();
                switch (filterBy.ToLower())
                {
                    case "cpf":
                        query = query.Where(s => s.Cpf.ToLower().Contains(searchLower));
                        break;
                    case "cidade":
                        query = query.Where(s =>
                                             (s.Cidade != null && s.Cidade.ToLower().Contains(searchLower)) ||
                                             s.Nome.ToLower().Contains(searchLower));
                        break;
                    default:
                        query = query.Where(s => s.Nome.ToLower().Contains(searchLower));
                        break;
                }
            }

            totalResults = query.Count();

            return query.Skip(page * lenght)
                        .Take(lenght);
        }
    }
}
