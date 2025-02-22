using Microsoft.AspNetCore.Identity;

namespace Core.Service
{
    public interface IPessoaService
    {
        uint Create(Pessoa pessoa, int idFrota);
        Task CreatePessoaPapelAsync(Pessoa pessoa, int idFrota, string papelPessoa);
        Task<UsuarioIdentity> CreateAsync(Pessoa pessoa);
        Task<string> GenerateEmailConfirmationTokenAsync(UsuarioIdentity user);
        Task<IdentityResult> ConfirmEmailAsync(string userId, string token);
        Task<UsuarioIdentity> GetUserByCpfAsync(string cpf);
        void Edit(Pessoa pessoa, int idFrota);
        void Delete(uint idPessoa);
        IEnumerable<Pessoa> GetAll(int idFrota);
        Pessoa? Get(uint idPessoa);
        uint GetPessoaIdUser();
        IEnumerable<Pessoa> GetPaged(int idFrota, int page, int lenght, out int totalResults, string? search = null, string filterBy = "Nome");
        public uint FindPapelPessoa(string Papel);
    }
}
