using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;


namespace Service
{
    public class PessoaService : IPessoaService
    {
        private readonly FrotaContext context;

        public PessoaService(FrotaContext context)
        {
            this.context = context;
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
            try
            {
                context.Add(pessoa);
                context.SaveChanges();
            }
            catch (Exception exception)
            {
                throw new ServiceException("Erro ao adicionar pessoa no banco de dados.", exception);
            }
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
                try
                {
                    context.Remove(pessoa);
                    context.SaveChanges();
                }
                catch (Exception exception)
                {
                    throw new ServiceException("Erro ao remover pessoa no banco de dados.", exception);
                }
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
            try
            {
                context.Update(pessoa);
                context.SaveChanges();
            }
            catch (Exception exception)
            {
                throw new ServiceException("Erro ao atualizar informações no banco de dados.", exception);
            }
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
        /// <returns>Uma coleção de pessoas da frota especificada</returns>
        public IEnumerable<Pessoa> GetAll(int idFrota)
        {
            return context.Pessoas
                          .Where(f => f.IdFrota == idFrota)
                          .AsNoTracking();
        }

        /// <summary>
        /// Obtém o Id de uma pessoa a partir do cpf informado
        /// </summary>
        /// <param name="cpf">O cpf da pessoa</param>
        /// <returns>O id da pessoa correspondente ao cpf ou 0 caso não seja encontrada</returns>
        public uint GetPessoaByCpf(string cpf)
        {
            return context.Pessoas
                          .AsNoTracking()
                          .Where(p => p.Cpf == cpf)
                          .Select(p => p.Id)
                          .FirstOrDefault();
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
