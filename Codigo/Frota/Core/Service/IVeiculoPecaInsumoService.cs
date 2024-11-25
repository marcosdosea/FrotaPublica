using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Core.Service
{
    public interface IVeiculoPecaInsumoService
    {
        void Create(Veiculopecainsumo veiculoPecaInsumo);
        void Edit(Veiculopecainsumo veiculoPecaInsumo);
        void Delete(Veiculopecainsumo veiculopecainsumo);
        Veiculopecainsumo? Get(uint IdVeiculo, uint IdPecaInsumo);
        IEnumerable<Veiculopecainsumo> GetAll();
    }
}
