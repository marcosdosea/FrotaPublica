using System;
using System.Collections.Generic;

namespace Core;

public partial class Modeloveiculo
{
    public uint Id { get; set; }

    public uint IdMarcaVeiculo { get; set; }

    public string Nome { get; set; } = null!;

    public int CapacidadeTanque { get; set; }

    public uint IdFrota { get; set; }

    public virtual Frotum IdFrotaNavigation { get; set; } = null!;

    public virtual Marcaveiculo IdMarcaVeiculoNavigation { get; set; } = null!;

    public virtual ICollection<Veiculo> Veiculos { get; set; } = new List<Veiculo>();
}
