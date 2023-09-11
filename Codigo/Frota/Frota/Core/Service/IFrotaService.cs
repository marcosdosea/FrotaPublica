using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
