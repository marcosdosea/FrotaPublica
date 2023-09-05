using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Core;
using Core.Service;

namespace Service
{
    public class ModeloVeiculoService : IModeloVeiculoService
    {
        private readonly FrotaContext _context;

        public ModeloVeiculoService(FrotaContext context)
        {
            _context = context;
        }

        // Inserir novo modelo de veiculo na base de dados
        public uint Create(Modeloveiculo modeloVeiculo)
        {
            _context.Add(modeloVeiculo);
            _context.SaveChanges();
            return modeloVeiculo.Id;
        }

        public void Delete(Modeloveiculo idVeiculo)
        {
            throw new NotImplementedException();
        }

        public void Edit(Modeloveiculo modeloVeiculo)
        {
            throw new NotImplementedException();
        }

        public Modeloveiculo Get(uint idVeiculo)
        {
            throw new NotImplementedException();
        }

        public IEnumerable<Modeloveiculo> GetAll()
        {
            throw new NotImplementedException();
        }
    }
}
