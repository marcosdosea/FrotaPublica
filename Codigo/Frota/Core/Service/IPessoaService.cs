namespace Core.Service
{
    public interface IPessoaService
    {
        uint Create(Pessoa pessoa, int idFrota);
        void Edit(Pessoa pessoa, int idFrota);
        void Delete(uint idPessoa);
        IEnumerable<Pessoa> GetAll(int idFrota);
        Pessoa? Get(uint idPessoa);
        uint GetIdPessoaByCpf(string cpf);
        IEnumerable<Pessoa> GetPaged(int idFrota, int page, int lenght, out int totalResults, string? search = null, string filterBy = "Nome");
    }
}
