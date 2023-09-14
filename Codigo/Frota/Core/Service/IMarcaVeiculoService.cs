using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Core.Service
{
    internal interface IMarcaVeiculoService
    {
        // Método para criar uma marca de veículo
        void CriarMarcaVeiculo(string nome);

        // Método para atualizar informações de uma marca de veículo
        void AtualizarMarcaVeiculo(string nome, string novoNome);

        // Método para excluir uma marca de veículo
        void ExcluirMarcaVeiculo(string nome);

        // Método para obter todas as marcas de veículos
        IEnumerable<string> ObterTodasAsMarcasVeiculo();

        // Propriedade para obter o número total de marcas de veículos
        int TotalMarcasVeiculo { get; }

        // Evento que é acionado quando uma nova marca de veículo é criada
        event EventHandler<string> MarcaVeiculoCriada;
    }
}
