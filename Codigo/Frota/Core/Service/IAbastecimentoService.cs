﻿namespace Core.Service
{
    public interface IAbastecimentoService
    {
        uint Create(Abastecimento abastecimento);
        void Edit(Abastecimento abastecimento);
        void Delete(uint idAbastecimento);
        Abastecimento? Get(uint idAbastecimento);
        IEnumerable<Abastecimento> GetAll(uint idFrota);
        IEnumerable<Abastecimento> GetPaged(int page, int lenght, int idFrota);
    }
}