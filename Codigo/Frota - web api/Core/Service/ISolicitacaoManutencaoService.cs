namespace Core.Service;

public interface ISolicitacaoManutencaoService
{
    uint Create(Solicitacaomanutencao solicitacao, int idFrota);

    void Edit(Solicitacaomanutencao solicitacao, int idFrota);

    void Delete(uint idSolicitacao);

    Solicitacaomanutencao? Get(uint idSolicitacao);

    IEnumerable<Solicitacaomanutencao> GetAll(int idFrota);

    IEnumerable<Solicitacaomanutencao> GetByData(DateTime data, int idFrota);

    IEnumerable<Solicitacaomanutencao> GetEntreData(DateTime dataInicio, DateTime dataFim, int idFrota);
}
