using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Core.Service
{
    public interface IAbastecimentoService
    {
        uint Create(Abastecimento abastecimento);
        void Edit(Abastecimento abastecimento);
        void Delete(uint idAbastecimento);
        Abastecimento Get(uint idAbastecimento);
        IEnumerable<Abastecimento> GetAll();
    }
}
