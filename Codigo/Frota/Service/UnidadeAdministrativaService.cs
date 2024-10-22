using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service
{
	public class UnidadeAdministrativaService : IUnidadeAdministrativaService
	{
		private readonly FrotaContext context;

		public UnidadeAdministrativaService(FrotaContext context)
		{
			this.context = context;
		}

		/// <summary>
		/// Adicionar nova unidade na base de dados
		/// </summary>
		/// <param name="unidadeAdministrativa"></param>
		/// <returns></returns>
		public uint Create(Unidadeadministrativa unidadeAdministrativa)
		{
			context.Add(unidadeAdministrativa);
			context.SaveChanges();
			return unidadeAdministrativa.Id;
		}

		/// <summary>
		/// Excluir uma unidade da base de dados
		/// </summary>
		/// <param name="id"></param>
		public void Delete(uint id)
		{
			var unidadeAdministrativa = context.Unidadeadministrativas.Find(id);
			if (unidadeAdministrativa != null)
			{
				context.Remove(unidadeAdministrativa);
				context.SaveChanges();
			}
		}

		/// <summary>
		/// Alterar os dados da unidade na base de dados
		/// </summary>
		/// <param name="unidadeAdministrativa"></param>
		public void Edit(Unidadeadministrativa unidadeAdministrativa)
		{
			context.Update(unidadeAdministrativa);
			context.SaveChanges();
		}

		/// <summary>
		/// Obter pelo id da unidade
		/// </summary>
		/// <param name="id"></param>
		/// <returns></returns>
		public Unidadeadministrativa? Get(uint id)
		{
			return context.Unidadeadministrativas.Find(id);
		}

		/// <summary>
		/// Obter a lista de unidades cadastradas
		/// </summary>
		/// <returns></returns>
		public IEnumerable<Unidadeadministrativa> GetAll()
		{
			return context.Unidadeadministrativas.AsNoTracking();
		}
	}
}

