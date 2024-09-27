using System;
using System.Collections.Generic;
using System.Formats.Asn1;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Core.Service
{
    public interface IPecaInsumoService
    {
        uint Create(Pecainsumo pecainsumo);
        void Edit(Pecainsumo pecainsumo);
        void Delete(uint idPeca);
        Pecainsumo? Get(uint idPeca);
        IEnumerable<Pecainsumo> GetAll();
    }
}
