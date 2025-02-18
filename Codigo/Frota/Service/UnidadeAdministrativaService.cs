﻿using Core;
using Core.DTO;
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
		public uint Create(Unidadeadministrativa unidadeAdministrativa, int idFrota)
		{
			unidadeAdministrativa.IdFrota = (uint)idFrota;
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
		public void Edit(Unidadeadministrativa unidadeAdministrativa, int idFrota)
		{
			unidadeAdministrativa.IdFrota = (uint)idFrota;
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
		public IEnumerable<Unidadeadministrativa> GetAll(uint idFrota)
		{
			return context.Unidadeadministrativas
						  .Where(frota => frota.IdFrota == idFrota)
						  .AsNoTracking();
		}

		/// <summary>
		/// Obter a lista de unidades cadastradas em ordem alfabética
		/// </summary>
		/// <returns></returns>
		public IEnumerable<UnidadeAdministrativaDTO> GetAllOrdemAlfabetica(uint idFrota)
		{
			var unidadeAdministrativaDTO = from unidadeAdministrativa in context.Unidadeadministrativas.AsNoTracking()
										   where unidadeAdministrativa.IdFrota == idFrota
										   orderby unidadeAdministrativa.Nome
										   select new UnidadeAdministrativaDTO
										   {
											   Id = unidadeAdministrativa.Id,
											   Nome = unidadeAdministrativa.Nome
										   };
			return unidadeAdministrativaDTO.ToList();
        }

	}
}
