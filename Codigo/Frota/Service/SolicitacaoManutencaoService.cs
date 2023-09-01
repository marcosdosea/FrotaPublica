using Core;
using Core.Service;

namespace Service;

public class SolicitacaoManutencaoService : ISolicitacaoManutencaoService
{
    private readonly FrotaContext _context;

    public SolicitacaoManutencaoService(FrotaContext context)
    {
        _context = context;
    }

    public uint Create(Solicitacaomanutencao solicitacao)
    {
        _context.Add(solicitacao);
        _context.SaveChanges();

        return solicitacao.Id;
    }

    public void Edit(Solicitacaomanutencao solicitacao)
    {
        _context.Update(solicitacao);
        _context.SaveChanges();
    }

    public void Delete(uint idSolicitacao)
    {
        var _solicitacao = _context.Solicitacaomanutencaos.Find(idSolicitacao);

        if (_solicitacao == null)
            return;

        _context.Remove(_solicitacao);
        _context.SaveChanges();
    }

    public Solicitacaomanutencao? Get(uint idSolicitacao)
    {
        return _context.Solicitacaomanutencaos.Find(idSolicitacao);
    }

    public IEnumerable<Solicitacaomanutencao> GetAll()
    {
        return _context.Solicitacaomanutencaos;
    }

    public IEnumerable<Solicitacaomanutencao> GetByData(DateTime data)
    {
        var query =
            from solicitacao in _context.Solicitacaomanutencaos
            where solicitacao.DataSolicitacao.CompareTo(data) == 0
            select solicitacao;

        return query;
    }

    public IEnumerable<Solicitacaomanutencao> GetEntreData(DateTime dataInicio, DateTime dataFim)
    {
        var query =
            from solicitacao in _context.Solicitacaomanutencaos
            where solicitacao.DataSolicitacao.CompareTo(dataInicio) >= 0
            where solicitacao.DataSolicitacao.CompareTo(dataFim) <= 0
            select solicitacao;

        throw new NotImplementedException();
    }
}
