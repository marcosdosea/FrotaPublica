namespace Core.Service
{
    public interface IAbastecimentoService
    {
        uint Create(Abastecimento abastecimento, int idFrota);
        void Edit(Abastecimento abastecimento, int idFrota);
        void Delete(uint idAbastecimento);
        Abastecimento? Get(uint idAbastecimento);
        IEnumerable<Abastecimento> GetPaged(int page, int lenght, int idFrota);
        IEnumerable<Abastecimento> GetAll(int idFrota);
    }
}
