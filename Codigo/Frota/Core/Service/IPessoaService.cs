using Microsoft.AspNetCore.Identity;

namespace Core.Service;

public interface IPessoaService
{
    uint Create(Pessoa pessoa, int idFrota);
    void Delete(uint idPessoa);
    void Edit(Pessoa pessoa, int idFrota);
    Pessoa? Get(uint idPessoa);
    IEnumerable<Pessoa> GetAll(int idFrota);
    uint GetPessoaIdUser();
    IEnumerable<Pessoa> GetPaged(int idFrota, int page, int lenght, out int totalResults, string? search = null, string filterBy = "Nome");
    uint FindPapelPessoa(string Papel);
    string? FindPapelPessoaById(uint idPapel);
    Task CreateAsync(Pessoa pessoa, int idFrota, string papelPessoa);
    Task<string> GenerateEmailConfirmationTokenAsync(UsuarioIdentity user);
    Task<IdentityResult> ConfirmEmailAsync(string userId, string token);
    Task<UsuarioIdentity> GetUserByCpfAsync(string cpf);
    Pessoa? GetUserByEmailAsync(string cpf);
    IEnumerable<Papelpessoa> GetPapeisPessoas(string papelUsuarioCadastrante);

}
