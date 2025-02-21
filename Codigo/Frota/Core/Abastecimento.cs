using System;
using System.Collections.Generic;

namespace Core;

public partial class Abastecimento
{
    public uint Id { get; set; }

    public uint IdFornecedor { get; set; }

    public uint IdVeiculo { get; set; }

    public int IdFrota { get; set; }

    public uint IdPessoa { get; set; }

    public DateTime DataHora { get; set; }

    public int Odometro { get; set; }

    public decimal Litros { get; set; }

    public virtual Fornecedor IdFornecedorNavigation { get; set; } = null!;

    public virtual Frotum IdFrotaNavigation { get; set; } = null!;

    public virtual Pessoa IdPessoaNavigation { get; set; } = null!;

    public virtual Veiculo IdVeiculoNavigation { get; set; } = null!;
}
