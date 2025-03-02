using Core;
using Core.Service;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System.Data;
using System.Security.Claims;
using System.Text;


namespace Service
{
    public class PessoaService : IPessoaService
    {
        private readonly FrotaContext context;
        private readonly UserManager<Core.UsuarioIdentity> userManager;
        private readonly RoleManager<IdentityRole> roleManager;
        private readonly IHttpContextAccessor httpContextAccessor;

        public PessoaService(FrotaContext context, UserManager<Core.UsuarioIdentity> userManager, RoleManager<IdentityRole> roleManager, IHttpContextAccessor httpContextAccessor)
        {
            this.userManager = userManager;
            this.roleManager = roleManager;
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
        public IEnumerable<Pessoa> GetAll(int idFrota, bool viewAll)
        {
            if (viewAll)
            {
                return context.Pessoas
                          .Where(f => f.IdPapelPessoa == 3)
                          .AsNoTracking();
            }
            else
            {
                return context.Pessoas
                          .Where(f => f.IdFrota == idFrota)
                          .AsNoTracking();
            }
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

        public IEnumerable<Pessoa> GetPaged(int idFrota, bool viewAll, int page, int lenght, out int totalResults, string? search = null, string filterBy = "Nome")
        {
            IQueryable<Pessoa> query = context.Pessoas.AsNoTracking(); // Declara a query antes dos blocos if

            if (viewAll)
            {
                query = query.Where(f => f.IdPapelPessoa == 3);
            }
            else
            {
                query = query.Where(f => f.IdFrota == idFrota);
            }


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

        public string? FindPapelPessoaById(uint idPapel)
        {
            return context.Papelpessoas.Where(papel => papel.Id == idPapel)
                                       .Select(papel => papel.Papel)
                                       .FirstOrDefault();
        }

        /// <summary>
        /// Método para realizar o cadastro de um usuário na tabela de usuários do identity
        /// </summary>
        /// <param name="pessoa"></param>
        /// <returns></returns>
        /// <exception cref="Exception"></exception>
        private async Task<UsuarioIdentity> CreateUserAsync(Pessoa pessoa)
        {
            var newUser = new UsuarioIdentity
            {
                UserName = pessoa.Cpf,
                NormalizedUserName = pessoa.Cpf.Replace(".", "").Replace("-", ""),
                Email = pessoa.Email,
                PhoneNumber = pessoa.Telefone
            };

            var result = await userManager.CreateAsync(newUser);

            if (result.Succeeded)
            {
                return userManager.FindByIdAsync(newUser.Id).Result;
            }
            else
            {
                throw new Exception("Falha ao criar o usuário.");
            }
        }

        private async Task CreateRoleForUserAsync(string papelPessoa, UsuarioIdentity? existingUser)
        {
            var roleExists = await roleManager.FindByNameAsync(papelPessoa);
            if (roleExists == null)
            {
                throw new Exception($"O papel '{papelPessoa}' não existe no sistema.");
            }

            using (var context = new FrotaContext())
            {
                try
                {
                    await context.Database.ExecuteSqlInterpolatedAsync(
                        $"INSERT INTO AspNetUserRoles (UserId, RoleId) VALUES ({existingUser.Id}, {roleExists.Id})"
                    );
                }
                catch (Exception ex)
                {
                    throw new Exception($"Erro ao associar o papel ao usuário no banco de dados: {ex.Message}", ex);
                }
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
        public async Task CreateAsync(Pessoa pessoa, int idFrota, string papelPessoa)
        {
            uint idPessoa = pessoa.Id;
            if (Get(pessoa.Id) == null)
            {
                idPessoa = Create(pessoa, idFrota);
            }

            var existingUser = await userManager.FindByNameAsync(pessoa.Cpf);
            if (existingUser == null)
            {
                existingUser = await CreateUserAsync(pessoa);
                if (existingUser == null)
                {
                    throw new Exception("Erro ao criar o usuário no sistema.");
                }
                await CreateRoleForUserAsync(papelPessoa, existingUser);
            }
        }

        

        public async Task<string> GenerateEmailConfirmationTokenAsync(UsuarioIdentity user)
        {
            return await userManager.GenerateEmailConfirmationTokenAsync(user);
        }

        public async Task<IdentityResult> ConfirmEmailAsync(string userId, string token)
        {
            var user = await userManager.FindByIdAsync(userId);
            if (user == null) throw new Exception("Usuário não encontrado.");

            return await userManager.ConfirmEmailAsync(user, token);
        }

        public async Task<UsuarioIdentity> GetUserByCpfAsync(string cpf)
        {
            return await userManager.FindByNameAsync(cpf);
        }
        public Pessoa? GetUserByEmailAsync(string email)
        {
            return context.Pessoas.FirstOrDefault(pessoa => pessoa.Email == email);
        }


        public IEnumerable<Papelpessoa> GetPapeisPessoas(string papelUsuarioCadastrante)
        {
            if(papelUsuarioCadastrante.ToLower() == "administrador")
            {
                return context.Papelpessoas.Where(papel => papel.Papel.ToLower() == "gestor").ToList();
            }
            else
            {
                return context.Papelpessoas.Where(papel => papel.Papel.ToLower() != "gestor" && papel.Papel.ToLower() != "administrador").ToList();
            }

        }
    }
}
