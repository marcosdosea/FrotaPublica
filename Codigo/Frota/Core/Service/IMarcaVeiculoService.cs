using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace Core.Service
{
    public interface IMarcaVeiculoService
    {
        Marcaveiculo Get(uint id);
        uint Create(string name);
        void Edit(string currentName, string newName);
        void Delete(string name);
        IEnumerable<string> GetAll();
        void Create(Marcaveiculo marcaveiculo);
        void Edit(Marcaveiculo marcaVeiculo);
        void Delete(uint id);

        int Total { get; }
        event EventHandler<string> MarcaVeiculoCreated;
    }
}
