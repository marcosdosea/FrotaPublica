﻿using Core.DTO;

namespace Core.Service
{
    public interface IFrotaService
    {
        uint Create(Frotum frota);
        void Edit(Frotum frota);
        bool Delete(int idFrota);
        Frotum? Get(int idFrota);
        uint GetFrotaByUsername(string username);
        IEnumerable<Frotum> GetAll();
        IEnumerable<FrotaDTO> GetAllOrdemAlfabetica();
    }
}
