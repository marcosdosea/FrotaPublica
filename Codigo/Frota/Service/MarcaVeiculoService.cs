using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Service
{
    internal class MarcaVeiculoService
    {
        private List<string> marcasDeVeiculo;

        public MarcaVeiculoService()
        {
            // Inicialize a lista de marcas de veículo.
            marcasDeVeiculo = new List<string>();
        }

        // Adicione uma marca de veículo à lista.
        public void AdicionarMarca(string marca)
        {
            marcasDeVeiculo.Add(marca);
        }

        // Obtenha todas as marcas de veículo da lista.
        public List<string> ObterTodasAsMarcas()
        {
            return marcasDeVeiculo;
        }

        // Verifique se uma marca específica existe na lista.
        public bool MarcaExiste(string marca)
        {
            return marcasDeVeiculo.Contains(marca);
        }
    }
}
