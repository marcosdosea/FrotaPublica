namespace Core.Service;

public interface ISolicitacaomanutencaoService
{
    uint Create(Solicitacaomanutencao solicitacao);

    void Edit(Solicitacaomanutencao solicitacao);

    void Delete(uint idSolicitacao);

    Solicitacaomanutencao? Get(uint idSolicitacao);

    IEnumerable<Solicitacaomanutencao> GetAll();

    IEnumerable<Solicitacaomanutencao> GetByData(DateTime data);

    IEnumerable<Solicitacaomanutencao> GetEntreData(DateTime dataInicio, DateTime dataFim);
}
