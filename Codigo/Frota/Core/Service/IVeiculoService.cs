using Core.DTO;

namespace Core.Service
{
    public interface IVeiculoService
    {
        uint Create(Veiculo veiculo, int idFrota);
        void Edit(Veiculo veiculo, int idFrota);
        void Delete(uint idVeiculo);
        Veiculo? Get(uint idVeiculo);
        IEnumerable<Veiculo> GetPaged(int page, int lenght, int idFrota);
        IEnumerable<Veiculo> GetAll(int idFrota);
        IEnumerable<VeiculoDTO> GetVeiculoDTO(int idFrota);
    }
}

