using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Core.Service
{
    public interface IModeloVeiculoService
    {
        uint Create(Modeloveiculo modeloVeiculo);
        void Edit(Modeloveiculo modeloVeiculo);
        void Delete(uint idVeiculo);
        Modeloveiculo Get(uint idVeiculo);
        IEnumerable<Modeloveiculo> GetAll();
    }
}
