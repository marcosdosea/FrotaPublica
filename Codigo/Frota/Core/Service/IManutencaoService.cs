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
        uint Create(Manutencao manutencao);
        void Edit(Manutencao manutencao);
        void Delete(uint id);
        Manutencao? Get(uint id);
        IEnumerable<Manutencao> GetAll();
    }
}