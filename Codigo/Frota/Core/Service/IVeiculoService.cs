using Core.DTO;

namespace Core.Service
{
    public interface IVeiculoService
    {
        uint Create(Veiculo veiculo);
        void Edit(Veiculo veiculo);
        void Delete(uint idVeiculo);
        Veiculo? Get(uint idVeiculo);
        IEnumerable<Veiculo> GetPaged(int page, int lenght, uint idFrota);
        PagedResult<Veiculo> GetVeiculosDisponiveisUnidadeAdministrativaPaged(int page, int length, uint idFrota, uint unidadeAdministrativa, string placa);
        IEnumerable<Veiculo> GetAll(uint idFrota);
        IEnumerable<VeiculoDTO> GetVeiculoDTO(int idFrota);
        string? GetPlacaVeiculo(uint idVeiculo);
    }
}

