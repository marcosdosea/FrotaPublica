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
		/// <param name="idManutencao">O id da manutenção</param>
		/// <param name="idPecaInsumo">O id da peça/insumo</param>
		public void Delete(uint idManutencao, uint idPecaInsumo)
		{
			var manutencaoPecaInsumo = context.Manutencaopecainsumos
			  .FirstOrDefault(manutencaopPecaInsumo => manutencaopPecaInsumo.IdManutencao == idManutencao && manutencaopPecaInsumo.IdPecaInsumo == idPecaInsumo);
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
		/// <param name="idManutencao">O id da manutenção</param>
		/// <param name="idPecaInsumo">O id da peça/insumo</param>
		/// <returns></returns>
		public Manutencaopecainsumo? Get(uint idManutencao, uint idPecaInsumo)
		{
			return context.Manutencaopecainsumos
			  .FirstOrDefault(manutencaopPecaInsumo => manutencaopPecaInsumo.IdManutencao == idManutencao && manutencaopPecaInsumo.IdPecaInsumo == idPecaInsumo);
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
