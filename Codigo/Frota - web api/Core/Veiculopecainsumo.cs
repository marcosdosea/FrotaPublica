using System;
using System.Collections.Generic;

namespace Core;

public partial class Veiculopecainsumo
{
    public uint IdVeiculo { get; set; }

    public uint IdPecaInsumo { get; set; }

    public DateTime DataFinalGarantia { get; set; }

    public int KmFinalGarantia { get; set; }

    public DateTime DataProximaTroca { get; set; }

    public int KmProximaTroca { get; set; }

    public virtual Pecainsumo IdPecaInsumoNavigation { get; set; } = null!;

    public virtual Veiculo IdVeiculoNavigation { get; set; } = null!;
}
