using Core.DTO;

namespace Core.Service
{
    public interface IUnidadeAdministrativaService
    {
        uint Create(Unidadeadministrativa unidadeAdministrativa, int idFrota);
        void Edit(Unidadeadministrativa unidadeAdministrativa, int idFrota);
        void Delete(uint id);
        Unidadeadministrativa? Get(uint id);
        IEnumerable<Unidadeadministrativa> GetAll(int idFrota);
        IEnumerable<UnidadeAdministrativaDTO> GetAllOrdemAlfabetica(int idFrota);
	}
}
