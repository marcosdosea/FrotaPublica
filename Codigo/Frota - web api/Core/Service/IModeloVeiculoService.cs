using Core.DTO;

namespace Core.Service
{
    public interface IModeloVeiculoService
    {
        uint Create(Modeloveiculo modeloVeiculo);
        void Edit(Modeloveiculo modeloVeiculo);
        void Delete(uint id);
        Modeloveiculo? Get(uint idVeiculo);
        IEnumerable<Modeloveiculo> GetAll(uint idFrota);
        IEnumerable<ModeloVeiculoDTO> GetAllOrdemAlfabetica(uint idFrota);
    }
}
