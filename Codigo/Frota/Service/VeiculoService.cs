using Core;
using Core.Service;

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
        /// Adicionar nova veiculo na base de dados
        /// </summary>
        /// <param name="veiculo"></param>
        /// <returns></returns>
        public uint Create(Veiculo veiculo)
        {
            context.Veiculos.Add(veiculo);
            context.SaveChanges();
            return veiculo.Id;
        }

        /// <summary>
        /// Excluir uma veiculo da base de dados
        /// </summary>
        /// <param name="idVeiculo"></param>
        public void Delete(uint idVeiculo)
        {
            var veiculo = context.Veiculos.Find(idVeiculo);

            if (veiculo == null)
                return;

            context.Veiculos.Remove(veiculo);
            context.SaveChanges();
        }

        /// <summary>
        /// Alterar os dados da veiculo na base de dados
        /// </summary>
        /// <param name="veiculo"></param>
        public void Edit(Veiculo veiculo)
        {
            context.Veiculos.Update(veiculo);
            context.SaveChanges();
        }

        /// <summary>
        /// Obter pelo id da veiculo
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
            return context.Veiculos;
        }
    }
}

