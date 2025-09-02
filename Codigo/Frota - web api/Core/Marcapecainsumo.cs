using System;
using System.Collections.Generic;

namespace Core;

public partial class Marcapecainsumo
{
    public uint Id { get; set; }

    public string Descricao { get; set; } = null!;

    public uint Idfrota { get; set; }

    public virtual Frotum IdfrotaNavigation { get; set; } = null!;

    public virtual ICollection<Manutencaopecainsumo> Manutencaopecainsumos { get; set; } = new List<Manutencaopecainsumo>();
}
