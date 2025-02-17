﻿namespace Core.Service
{
    public interface IPessoaService
    {
        uint Create(Pessoa pessoa);
        void Edit(Pessoa pessoa);
        void Delete(uint idPessoa);
        IEnumerable<Pessoa> GetAll();
        Pessoa? Get(uint idPessoa);
        uint GetPessoaIdUser();
        IEnumerable<Pessoa> GetPaged(int page, int lenght, out int totalResults, string search = null, string filterBy = "Nome");
    }
}
