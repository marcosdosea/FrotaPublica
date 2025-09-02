using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Service;

public class PercursoService : IPercursoService
{
	private readonly FrotaContext context;
	public PercursoService(FrotaContext context)
	{
		this.context = context;
	}
	/// <summary>
	/// Cria um novo percurso na base de dados
	/// </summary>
	/// <param name="percurso"></param>
	/// <returns>Retorna o id do percurso registrado</returns>
	public uint Create(Percurso percurso)
	{
		context.Add(percurso);
		context.SaveChanges();
		return percurso.Id;
	}
	/// <summary>
	/// Deleta um percurso da base de dados
	/// </summary>
	/// <param name="idPercurso"></param>
	public void Delete(uint idPercurso)
	{
		var percurso = context.Percursos.Find(idPercurso);
		if (percurso != null)
		{
			context.Remove(percurso);
			context.SaveChanges();
		}
	}
	/// <summary>
	/// Edita um percurso na base de dados
	/// </summary>
	/// <param name="percurso"></param>
	public void Edit(Percurso percurso)
	{
		context.Update(percurso);
		context.SaveChanges();
	}
	/// <summary>
	/// Obtem um percurso pelo id
	/// </summary>
	/// <param name="idPercurso"></param>
	/// <returns>Retorna o percurso obtido, se for existente</returns>
	public Percurso? Get(uint idPercurso)
	{
		return context.Percursos.Find(idPercurso);
	}
	/// <summary>
	/// Obtem uma lista de todos os percursos
	/// </summary>
	/// <returns></returns>
	public IEnumerable<Percurso> GetAll()
	{
		return context.Percursos.AsNoTracking();
	}

	/// <summary>
	/// Busca um percurso corrente para determinado motorista
	/// </summary>
	/// <param name="idPessoa"></param>
	/// <returns></returns>
	public Percurso? ObterPercursosAtualDoMotorista(int idPessoa)
	{
		return context.Percursos.FirstOrDefault(p => p.IdPessoa == idPessoa && p.DataHoraRetorno == DateTime.MinValue);
	}

	/// <summary>
	/// Obtém o id do veículo de determinado percurso
	/// </summary>
	/// <param name="idPercurso"></param>
	/// <returns></returns>
	public uint ObterVeiculoDePercurso(uint idPercurso)
	{
		return context.Percursos.FirstOrDefault(p => p.Id == idPercurso).IdVeiculo;
	}
}
