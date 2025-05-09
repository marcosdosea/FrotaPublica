namespace Core.Service
{
    public interface IPecaInsumoService
    {
        uint Create(Pecainsumo pecainsumo);
        void Edit(Pecainsumo pecainsumo);
        void Delete(uint idPeca);
        Pecainsumo? Get(uint idPeca);
        IEnumerable<Pecainsumo> GetAll(uint idFrota);
    }
}
