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

        /// <summary>
        /// Inserir novo modelo de veiculo na base de dados
        /// </summary>
        public uint Create(Modeloveiculo modeloVeiculo)
        {
            _context.Add(modeloVeiculo);
            _context.SaveChanges();
            return modeloVeiculo.Id;
        }

        /// <summary>
        //  Remover um veiculo da base de dados
        /// </summary>
        public void Delete(Modeloveiculo idVeiculo)
        {
            var modeloVeiculo = _context.Modeloveiculos.Find(idVeiculo);
            _context.Remove(idVeiculo);
            _context.SaveChanges();

        }


        /// <summary>
        /// Atualizar as informações de um veiculo na base de dados
        /// </summary>
        public void Edit(Modeloveiculo modeloVeiculo)
        {
            _context.Update(modeloVeiculo);
            _context.SaveChanges();
        }

        
        /// <summary>
        //  Retorna um modelo de veiculo da base de dados
        /// </summary>
        public Modeloveiculo Get(uint idVeiculo)
        {
            return _context.Modeloveiculos.Find(idVeiculo);
        }

        /// <summary>
        //  Obter uma lista dos modelos dos veiculos na base de dados
        /// </summary>
        public IEnumerable<Modeloveiculo> GetAll()
        {
            return _context.Modeloveiculos;
        }
    }
}
