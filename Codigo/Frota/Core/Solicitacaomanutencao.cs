using System;
using System.Collections.Generic;

namespace Core;

public partial class Solicitacaomanutencao
{
    public uint Id { get; set; }

    public uint IdVeiculo { get; set; }

    public uint IdPessoa { get; set; }

    public DateTime DataSolicitacao { get; set; }

    public string DescricaoProblema { get; set; } = null!;

    public int IdFrota { get; set; }

    public virtual Frotum IdFrotaNavigation { get; set; } = null!;

    public virtual Pessoa IdPessoaNavigation { get; set; } = null!;

    public virtual Veiculo IdVeiculoNavigation { get; set; } = null!;
}
