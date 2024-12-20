using Core.DTO;

namespace Core.Service
{
    public interface IFrotaService
    {
        uint Create(Frotum frota);
        void Edit(Frotum frota);
        bool Delete(uint idFrota);
        Frotum? Get(uint idFrota);
        uint GetFrotaByUser();
        IEnumerable<Frotum> GetAll();
        IEnumerable<FrotaDTO> GetAllOrdemAlfabetica();

	}
}
