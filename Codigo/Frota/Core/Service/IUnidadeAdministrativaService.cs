namespace Core.Service
{
    public interface IUnidadeAdministrativaService
    {
        uint Create(Unidadeadministrativa unidadeAdministrativa);
        void Edit(Unidadeadministrativa unidadeAdministrativa);
        void Delete(uint id);
        Unidadeadministrativa? Get(uint id);
        IEnumerable<Unidadeadministrativa> GetAll();
	}
}
