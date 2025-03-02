﻿using System;
using System.Collections.Generic;

namespace Core;

public partial class Pecainsumo
{
    public uint Id { get; set; }

    public string Descricao { get; set; } = null!;

    public int MesesGarantia { get; set; }

    public int KmGarantia { get; set; }

    public uint IdFrota { get; set; }

    public virtual Frotum IdFrotaNavigation { get; set; } = null!;

    public virtual ICollection<Manutencaopecainsumo> Manutencaopecainsumos { get; set; } = new List<Manutencaopecainsumo>();

    public virtual ICollection<Veiculopecainsumo> Veiculopecainsumos { get; set; } = new List<Veiculopecainsumo>();
}
