using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service
{
	public class MarcaVeiculoService : IMarcaVeiculoService
	{
		private readonly FrotaContext context;

		public MarcaVeiculoService(FrotaContext context)
		{
			this.context = context;
		}

		/// <summary>
		/// Adicionar nova veiculo na base de dados
		/// </summary>
		/// <param name="marcaVeiculo"></param>
		/// <returns></returns>
		public uint Create(Marcaveiculo marcaVeiculo, int idFrota)
		{
			marcaVeiculo.IdFrota = (uint)idFrota;
			context.Add(marcaVeiculo);
			context.SaveChanges();
			return marcaVeiculo.Id;
		}

		/// <summary>
		/// Excluir uma veiculo da base de dados
		/// </summary>
		/// <param name="id"></param>
		public void Delete(uint id)
		{
			var veiculo = context.Marcaveiculos.Find(id);
			context.Remove(veiculo);
			context.SaveChanges();
		}

		/// <summary>
		/// Alterar os dados da veiculo na base de dados
		/// </summary>
		/// <param name="marcaVeiculo"></param>
		public void Edit(Marcaveiculo marcaVeiculo, int idFrota)
		{
			marcaVeiculo.IdFrota = (uint)idFrota;
            context.Update(marcaVeiculo);
			context.SaveChanges();
		}

		/// <summary>
		/// Obter pelo id da veiculo
		/// </summary>
		/// <param name="marcaVeiculo"></param>
		/// <returns></returns>
		public Marcaveiculo? Get(uint marcaVeiculo)
		{
			return context.Marcaveiculos.Find(marcaVeiculo);
		}

		/// <summary>
		/// Obter a lista de veiculo cadastradas
		/// </summary>
		/// <returns></returns>
		public IEnumerable<Marcaveiculo> GetAll(int idFrota)
		{
			return context.Marcaveiculos
						  .Where(marca => marca.IdFrota == idFrota)
						  .AsNoTracking();
		}
	}
}

