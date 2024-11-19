using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service
{
	public class ManutencaoPecaInsumoService : IManutencaoPecaInsumoService
	{
		private readonly FrotaContext context;

		public ManutencaoPecaInsumoService(FrotaContext context)
		{
			this.context = context;
		}

		/// <summary>
		/// Adiciona nova manutencão de peça/insumo na base de dados
		/// </summary>
		/// <param name="manutencaoPecaInsumo"></param>
		/// <returns></returns>
		public uint Create(Manutencaopecainsumo manutencaoPecaInsumo)
		{
			context.Add(manutencaoPecaInsumo);
			context.SaveChanges();
			return manutencaoPecaInsumo.IdManutencao;
		}

		/// <summary>
		/// Exclui uma manutencão de peça/insumo da base de dados
		/// </summary>
		/// <param name="id"></param>
		public void Delete(uint id)
		{
			var manutencaoPecaInsumo = context.Manutencaopecainsumos.Find(id);
			if (manutencaoPecaInsumo != null)
			{
				context.Remove(manutencaoPecaInsumo);
				context.SaveChanges();
			}
		}

		/// <summary>
		/// Altera os dados de uma manutencão de peça/insumo na base de dados
		/// </summary>
		/// <param name="manutencaoPecaInsumo"></param>
		public void Edit(Manutencaopecainsumo manutencaoPecaInsumo)
		{
			context.Update(manutencaoPecaInsumo);
			context.SaveChanges();
		}

		/// <summary>
		/// Obter uma manutencão de peça/insumo pelo id
		/// </summary>
		/// <param name="id"></param>
		/// <returns></returns>
		public Manutencaopecainsumo? Get(uint id)
		{
			return context.Manutencaopecainsumos.Find(id);
		}

		/// <summary>
		/// Obter a lista de manutencões de peças/insumos cadastradas
		/// </summary>
		/// <returns></returns>
		public IEnumerable<Manutencaopecainsumo> GetAll()
		{
			return context.Manutencaopecainsumos.AsNoTracking();
		}
	}
}
