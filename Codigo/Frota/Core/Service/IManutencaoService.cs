using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Core;
using Core.Service;

namespace Service
{ 
		public interface IManutencaoService
	{
		IEnumerable<ManutencaoVeiculo> ListarManutencoes();
		ManutencaoVeiculo ObterManutencaoPorId(int id);
		void AdicionarManutencao(ManutencaoVeiculo manutencao);
		void AtualizarManutencao(ManutencaoVeiculo manutencao);
		void ExcluirManutencao(int id);
	}

	public class ManutencaoVeiculo
	{
		public int Id { get; set; }
		public string Descricao { get; set; }
		public DateTime Data { get; set; }
		public decimal Valor { get; set; }
		// Outros campos relevantes
	}
}