using Core.DTO;

namespace Core.Service
{
    public interface IFrotaService
    {
        uint Create(Frota frota);
        void Edit(Frota frota);
        bool Delete(uint idFrota);
        Frota? Get(uint idFrota);
        IEnumerable<Frota> GetAll();
        IEnumerable<FrotaDTO> GetAllOrdemAlfabetica();

	}
}
