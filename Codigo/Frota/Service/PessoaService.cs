using Core;
using Core.Service;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;


namespace Service
{
    public class PessoaService : IPessoaService
    {
        private readonly FrotaContext context;
        private readonly UserManager<UsuarioIdentity> userManager;
        private readonly IHttpContextAccessor httpContextAccessor;

        public PessoaService(FrotaContext context, UserManager<UsuarioIdentity> userManager, IHttpContextAccessor httpContextAccessor)
        {
            this.userManager = userManager;
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
        /// Método para realizar o cadastro de um usuário na tabela de usuários do identity
        /// </summary>
        /// <param name="pessoa"></param>
        /// <returns></returns>
        /// <exception cref="Exception"></exception>
        public async Task<UsuarioIdentity> CreateAsync(Pessoa pessoa)
        {
            var newUser = new UsuarioIdentity
            {
                UserName = pessoa.Cpf,
                NormalizedUserName = pessoa.Cpf.Replace(".", "").Replace("-", ""),
                Email = pessoa.Email,
                PhoneNumber = pessoa.Telefone
            };

            var result = await userManager.CreateAsync(newUser, pessoa.Cpf);

            if (result.Succeeded)
            {
                return newUser;
            }
            else
            {
                throw new Exception("Falha ao criar o usuário.");
            }
        }

        /// <summary>
        /// Método para realizar o cadastro dos papeis de usuário no identity
        /// </summary>
        /// <param name="pessoa"></param>
        /// <param name="idFrota"></param>
        /// <param name="papelPessoa"></param>
        /// <returns></returns>
        /// <exception cref="Exception"></exception>
        public async Task CreatePessoaPapelAsync(Pessoa pessoa, int idFrota, string papelPessoa)
        {
            uint idPessoa = pessoa.Id;
            if (Get(pessoa.Id) == null)
            {
                idPessoa = Create(pessoa, idFrota);
            }

            var existingUser = await userManager.FindByNameAsync(pessoa.Cpf);

            if (existingUser == null)
            {
                existingUser = await CreateAsync(pessoa);
            }

            /*var novaInscricao = new Inscricaopessoaevento
            {
                IdPessoa = idPessoa,
                IdEvento = idEvento,
                IdPapel = idPapel,
                DataInscricao = DateTime.Now,
                Status = "S"
            };
            _inscricaoService.CreateInscricaoEvento(novaInscricao);*/


            if (papelPessoa == "GESTOR")
            {
                try
                {
                    await userManager.AddClaimAsync(existingUser, new Claim("GESTOR", "true"));
                }
                catch (Exception e)
                {
                    throw new Exception("Erro ao adicionar claim de gestor ao usuário: " + e.Message);
                }
            }
            else if (papelPessoa == "ADMINISTRADOR")
            {
                try
                {
                    await userManager.AddClaimAsync(existingUser, new Claim("ADMINISTRADOR", "true"));
                }
                catch (Exception e)
                {
                    throw new Exception("Erro ao adicionar claim de colaborador ao usuário: " + e.Message);
                }
            }
            else if (papelPessoa == "MOTORISTA")
            {
                try
                {
                    await userManager.AddClaimAsync(existingUser, new Claim("MOTORISTA", "true"));
                }
                catch (Exception e)
                {
                    throw new Exception("Erro ao adicionar claim de colaborador ao usuário: " + e.Message);
                }
            }
            else 
            {
                try
                {
                    await userManager.AddClaimAsync(existingUser, new Claim("MECANICO", "true"));
                }
                catch (Exception e)
                {
                    throw new Exception("Erro ao adicionar claim de colaborador ao usuário: " + e.Message);
                }
            }

            var isInRole = await userManager.IsInRoleAsync(existingUser, papelPessoa);
            if (!isInRole)
            {
                var roleResult = await userManager.AddToRoleAsync(existingUser, papelPessoa);
                if (!roleResult.Succeeded)
                {
                    throw new Exception("Erro ao associar o papel ao usuário no Identity.");
                }
            }
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

        public uint FindPapelPessoa(string Papel)
        {
            return context.Papelpessoas.Where(papel => papel.Papel.ToUpper() == Papel.ToUpper())
                                       .Select(papel => papel.Id)
                                       .FirstOrDefault();
        }
    }
}
