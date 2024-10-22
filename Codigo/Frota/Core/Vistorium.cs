using System;
using System.Collections.Generic;

namespace Core;

public partial class Vistorium
{
    public uint Id { get; set; }

    public DateTime Data { get; set; }

    public string Problemas { get; set; } = null!;

    public string Tipo { get; set; } = null!;

    public uint IdPessoaResponsavel { get; set; }

    public virtual Pessoa IdPessoaResponsavelNavigation { get; set; } = null!;
}
