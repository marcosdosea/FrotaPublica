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

        void Editar(Pecainsumo pecainsumo);

       void Deletar(uint IdPeca);

        Pecainsumo Obter (uint IdPeca);
        
        IEnumerable<Pecainsumo> GetAll();
    }
}
