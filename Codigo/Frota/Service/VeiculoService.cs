using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service
{
    public class VeiculoService : IVeiculoService
    {
        private readonly FrotaContext context;

        public VeiculoService(FrotaContext context)
        {
            this.context = context;
        }

        /// <summary>
        /// Adiciona novo veículo na base de dados
        /// </summary>
        /// <param name="veiculo"></param>
        /// <returns></returns>
        public uint Create(Veiculo veiculo)
        {
            context.Add(veiculo);
            context.SaveChanges();
            return veiculo.Id;
        }

        /// <summary>
        /// Exclui um veículo da base de dados
        /// </summary>
        /// <param name="idVeiculo"></param>
        public void Delete(uint idVeiculo)
        {
            var veiculo = context.Veiculos.Find(idVeiculo);
            if (veiculo != null)
            {
                context.Remove(veiculo);
                context.SaveChanges();
            }
        }

        /// <summary>
        /// Altera os dados da veiculo na base de dados
        /// </summary>
        /// <param name="veiculo"></param>
        public void Edit(Veiculo veiculo)
        {
            context.Update(veiculo);
            context.SaveChanges();
        }

        /// <summary>
        /// Obter um veículo pelo id
        /// </summary>
        /// <param name="idVeiculo"></param>
        /// <returns></returns>
        public Veiculo? Get(uint idVeiculo)
        {
            return context.Veiculos.Find(idVeiculo);
        }

        /// <summary>
        /// Obter a lista de veiculo cadastradas
        /// </summary>
        /// <returns></returns>
        public IEnumerable<Veiculo> GetAll()
        {
            return context.Veiculos.AsNoTracking();
        }
    }
}

