namespace Core;

public partial class Manutencao
{
    public uint Id { get; set; }

    public uint IdVeiculo { get; set; }

    public uint IdFornecedor { get; set; }

    public DateTime DataHora { get; set; }

    public uint IdResponsavel { get; set; }

    public decimal ValorPecas { get; set; }

    public decimal ValorManutencao { get; set; }

    public string Tipo { get; set; } = null!;

    public byte[]? Comprovante { get; set; }

    public string Status { get; set; } = null!;

    public virtual Fornecedor IdFornecedorNavigation { get; set; } = null!;

    public virtual Pessoa IdResponsavelNavigation { get; set; } = null!;

    public virtual Veiculo IdVeiculoNavigation { get; set; } = null!;

    public virtual ICollection<Manutencaopecainsumo> Manutencaopecainsumos { get; set; } = new List<Manutencaopecainsumo>();
}
