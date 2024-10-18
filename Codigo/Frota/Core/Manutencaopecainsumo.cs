namespace Core;

public partial class Manutencaopecainsumo
{
    public uint IdManutencao { get; set; }

    public uint IdPecaInsumo { get; set; }

    public uint IdMarcaPecaInsumo { get; set; }

    public float Quantidade { get; set; }

    public int MesesGarantia { get; set; }

    public int KmGarantia { get; set; }

    public decimal ValorIndividual { get; set; }

    public decimal Subtotal { get; set; }

    public virtual Manutencao IdManutencaoNavigation { get; set; } = null!;

    public virtual Marcapecainsumo IdMarcaPecaInsumoNavigation { get; set; } = null!;

    public virtual Pecainsumo IdPecaInsumoNavigation { get; set; } = null!;
}
