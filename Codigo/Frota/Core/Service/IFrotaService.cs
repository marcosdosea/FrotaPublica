namespace Core.Service
{
    public interface IFrotaService
    {
        uint Create(Frota frota);
        void Edit(Frota frota);
        void Delete(uint idFrota);
        Frota Get(uint idFrota);
        IEnumerable<Frota> GetAll();
    }
}
