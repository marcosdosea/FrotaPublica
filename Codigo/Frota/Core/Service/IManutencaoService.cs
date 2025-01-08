using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Core;
using Core.Service;

namespace Service
{
    public interface IManutencaoService
    {
        uint Create(Manutencao manutencao, int idFrota);
        void Edit(Manutencao manutencao, int idFrota);
        void Delete(uint id);
        Manutencao? Get(uint id);
        IEnumerable<Manutencao> GetAll(int idFrota);
    }
}