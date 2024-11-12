namespace Core;

public partial class Veiculo
{
    public uint Id { get; set; }

    public string Placa { get; set; } = null!;

    public string? Chassi { get; set; }

    public string Cor { get; set; } = null!;

    public uint IdModeloVeiculo { get; set; }

    public uint IdFrota { get; set; }

    public uint IdUnidadeAdministrativa { get; set; }

    public int Odometro { get; set; }

    public string Status { get; set; } = null!;

    public int Ano { get; set; }

    public int Modelo { get; set; }

    public string? Renavan { get; set; }

    public DateTime? VencimentoIpva { get; set; }

    public decimal Valor { get; set; }

    public DateTime DataReferenciaValor { get; set; }

    public virtual Frotum IdFrotaNavigation { get; set; } = null!;

    public virtual Modeloveiculo IdModeloVeiculoNavigation { get; set; } = null!;

    public virtual Unidadeadministrativa IdUnidadeAdministrativaNavigation { get; set; } = null!;

    public virtual ICollection<Manutencao> Manutencaos { get; set; } = new List<Manutencao>();

    public virtual ICollection<Percurso> Percursos { get; set; } = new List<Percurso>();

    public virtual ICollection<Solicitacaomanutencao> Solicitacaomanutencaos { get; set; } = new List<Solicitacaomanutencao>();

    public virtual ICollection<Veiculopecainsumo> Veiculopecainsumos { get; set; } = new List<Veiculopecainsumo>();
}
