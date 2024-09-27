using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service
{
	public class VistoriaService : IVistoriaService
	{
		private readonly FrotaContext context;

		public VistoriaService(FrotaContext context)
		{
			this.context = context;
		}
		/// <summary>
		/// Cadastra uma nova vistoria
		/// </summary>
		/// <param name="vistoria"></param>
		/// <returns></returns>
		/// <exception cref="NotImplementedException"></exception>
		public int Create(Vistorium vistoria)
		{
			context.Add(vistoria);
			context.SaveChanges();
			return vistoria.Id;
		}
		/// <summary>
		/// Exclui uma vistoria na base de dados
		/// </summary>
		/// <param name="id"></param>
		/// <exception cref="NotImplementedException"></exception>
		public void Delete(uint id)
		{
			var vistoria = context.Pessoas.Find(id);
			if (vistoria != null) { 
				context.Remove(vistoria);
				context.SaveChanges();
			}
		}
		/// <summary>
		/// Edita uma vistoria na base de dados
		/// </summary>
		/// <param name="vistoria"></param>
		/// <exception cref="NotImplementedException"></exception>
		public void Edit(Vistorium vistoria)
		{
			context.Update(vistoria);
			context.SaveChanges();
		}
		/// <summary>
		/// Busca uma pessoa cadastrada
		/// </summary>
		/// <param name="id"></param>
		/// <returns></returns>
		/// <exception cref="NotImplementedException"></exception>
		public Vistorium? Get(uint id)
		{
			return context.Vistoria.Find(id);
		}

		/// <summary>
		/// Busca todas as pessoas cadastradas
		/// </summary>
		/// <returns></returns>
		public IEnumerable<Vistorium> GetAll()
		{
			return context.Vistoria.AsNoTracking();
		}
	}
}
