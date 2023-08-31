using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Core.Service
{
    public interface IPessoaService
    {
        uint Creat(Pessoa pessoa);
        void Edit(Pessoa pessoa);
        void Delete(uint idPessoa);
        IEnumerable<Pessoa> GetAll();
    }
}
