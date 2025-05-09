using Core.DTO;

namespace Core.Service
{
    public interface IFornecedorService
    {
        uint Create(Fornecedor fornecedor, int idFrota);
        void Edit(Fornecedor fornecedor, int idFrota);
        bool Delete(uint idFornecedor);
        Fornecedor? Get(uint idFornecedor);
        IEnumerable<Fornecedor> GetAll(int idFrota);
        Task<(bool Success, string Data)> ConsultaCnpj(string cnpj);
        IEnumerable<FornecedorDTO> GetAllOrdemAlfabetica(int idFrota);
    }
}
