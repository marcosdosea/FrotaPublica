using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Core;
using Core.Service;

namespace Service
{
	public class ManutencaoService : IManutencaoService
	{
		private readonly List<ManutencaoVeiculo> manutencoes = new List<ManutencaoVeiculo>();

		public IEnumerable<ManutencaoVeiculo> ListarManutencoes()
		{
			return manutencoes;
		}

		public ManutencaoVeiculo ObterManutencaoPorId(int id)
		{
			return manutencoes.FirstOrDefault(m => m.Id == id);
		}

		public void AdicionarManutencao(ManutencaoVeiculo manutencao)
		{
			if (manutencao == null)
			{
				throw new ArgumentNullException(nameof(manutencao));
			}

			// Gere um ID único, por exemplo, usando um contador
			manutencao.Id = GerarNovoId();
			manutencoes.Add(manutencao);
		}

		public void AtualizarManutencao(ManutencaoVeiculo manutencao)
		{
			if (manutencao == null)
			{
				throw new ArgumentNullException(nameof(manutencao));
			}

			var existente = manutencoes.FirstOrDefault(m => m.Id == manutencao.Id);
			if (existente != null)
			{
				existente.Descricao = manutencao.Descricao;
				existente.Data = manutencao.Data;
				existente.Valor = manutencao.Valor;
				// Atualize outros campos conforme necessário
			}
		}

		public void ExcluirManutencao(int id)
		{
			var existente = manutencoes.FirstOrDefault(m => m.Id == id);
			if (existente != null)
			{
				manutencoes.Remove(existente);
			}
		}

		private int GerarNovoId()
		{
			// Gere um novo ID único (por exemplo, com base no tamanho da lista + 1)
			return manutencoes.Count + 1;
		}
	}
}