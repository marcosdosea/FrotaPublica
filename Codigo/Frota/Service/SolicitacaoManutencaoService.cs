using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service;

public class SolicitacaoManutencaoService : ISolicitacaoManutencaoService
{
    private readonly FrotaContext _context;

    public SolicitacaoManutencaoService(FrotaContext context)
    {
        _context = context;
    }

    /// <summary>
    /// Adiciona uma nova solicitação de manutenção.
    /// </summary>
    /// <param name="solicitacao">Solicitação a ser adicionada.<param>
    /// <returns>
    /// Retorna o número identificador da nova solicitação.
    /// </returns>
    public uint Create(Solicitacaomanutencao solicitacao)
    {
        _context.Add(solicitacao);
        _context.SaveChanges();

        return solicitacao.Id;
    }

    /// <summary>
    /// Modifica uma solicitação de manutenção.
    /// </summary>
    /// <param name="solicitacao">Solicitação modificada.</param>
    public void Edit(Solicitacaomanutencao solicitacao)
    {
        _context.Update(solicitacao);
        _context.SaveChanges();
    }

    /// <summary>
    /// Remove uma solicitação de manutenção.
    /// </summary>
    /// <param name="idSolicitacao">Identificador da solicitação.</param>
    public void Delete(uint idSolicitacao)
    {
        var _solicitacao = _context.Solicitacaomanutencaos.Find(idSolicitacao);

        if (_solicitacao == null)
            return;

        _context.Remove(_solicitacao);
        _context.SaveChanges();
    }

    /// <summary>
    /// A partir de uma ID obtém uma solicitação.
    /// </summary>
    /// <param name="idSolicitacao">Identificador da solicitação.</param>
    /// <returns>
    /// Retorna a solicitação requerida ou <c>null</c> caso não encontrada.
    /// </returns>
    public Solicitacaomanutencao? Get(uint idSolicitacao)
    {
        return _context.Solicitacaomanutencaos.Find(idSolicitacao);
    }

    /// <summary>
    /// Obtém todas a solicitações.
    /// </summary>
    /// <returns>
    /// Retorna uma lista contendo todas as solicitações de manutenção.
    /// </returns>
    public IEnumerable<Solicitacaomanutencao> GetAll()
    {
        return _context.Solicitacaomanutencaos.AsNoTracking();
    }

    /// <summary>
    /// Usada para obter as solicitações feitas em uma data.
    /// </summary>
    /// <param name="data">Data usada para buscar as solicitações</param>
    /// <returns>
    /// Retorna uma lista de solicitações para uma determinada data.
    /// </returns>
    public IEnumerable<Solicitacaomanutencao> GetByData(DateTime data)
    {
        var query =
            from solicitacao in _context.Solicitacaomanutencaos
            where solicitacao.DataSolicitacao.CompareTo(data) == 0
            select solicitacao;

        return query.AsNoTracking();
    }

    /// <summary>
    /// Usada para obter as solicitações feitas em uma janela de tempo.
    /// </summary>
    /// <param name="dataInicio">Data inicial do período de busca de solicitações.</param>
    /// <param name="dataFim">Data final do período.</param>
    /// <returns>
    /// Retorna uma lista de solicitações para uma determinado período de tempo.
    /// </returns>
    public IEnumerable<Solicitacaomanutencao> GetEntreData(DateTime dataInicio, DateTime dataFim)
    {
        var query =
            from solicitacao in _context.Solicitacaomanutencaos
            where solicitacao.DataSolicitacao.CompareTo(dataInicio) >= 0
            where solicitacao.DataSolicitacao.CompareTo(dataFim) <= 0
            select solicitacao;

        return query.AsNoTracking();
    }
}
