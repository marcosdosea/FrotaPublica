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
            var modeloVeiculo = _context.Modeloveiculos.Find(idVeiculo);
            _context.Remove(idVeiculo);
            _context.SaveChanges();

        }

        public void Edit(Modeloveiculo modeloVeiculo)
        {
            _context.Update(modeloVeiculo);
            _context.SaveChanges();
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
