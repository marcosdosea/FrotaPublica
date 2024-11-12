namespace Core;

public partial class Percurso
{
    public uint IdVeiculo { get; set; }

    public uint IdPessoa { get; set; }

    public DateTime DataHoraSaida { get; set; }

    public DateTime DataHoraRetorno { get; set; }

    public string LocalPartida { get; set; } = null!;

    public float? LatitudePartida { get; set; }

    public float? LongitudePartida { get; set; }

    public string LocalChegada { get; set; } = null!;

    public float? LatitudeChegada { get; set; }

    public float? LongitudeChegada { get; set; }

    public int OdometroInicial { get; set; }

    public int OdometroFinal { get; set; }

    public string? Motivo { get; set; }

    public virtual ICollection<Abastecimento> Abastecimentos { get; set; } = new List<Abastecimento>();

    public virtual Pessoa IdPessoaNavigation { get; set; } = null!;

    public virtual Veiculo IdVeiculoNavigation { get; set; } = null!;
}
