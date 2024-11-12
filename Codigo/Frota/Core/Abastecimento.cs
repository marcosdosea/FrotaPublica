namespace Core;

public partial class Abastecimento
{
    public uint Id { get; set; }

    public uint IdVeiculoPercurso { get; set; }

    public uint IdPessoaPercurso { get; set; }

    public DateTime DataHora { get; set; }

    public int Odometro { get; set; }

    public int Litros { get; set; }

    public uint IdFornecedor { get; set; }

    public virtual Fornecedor IdFornecedorNavigation { get; set; } = null!;

    public virtual Percurso Percurso { get; set; } = null!;
}
