namespace Core.Service
{
    public interface IMarcaPecaInsumoService
    {
        uint Create(Marcapecainsumo marcapecainsumo);
        void Edit(Marcapecainsumo marcapecainsumo);
        void Delete(uint id);
        Marcapecainsumo? Get(uint id);
        IEnumerable<Marcapecainsumo> GetAll();
    }
}
