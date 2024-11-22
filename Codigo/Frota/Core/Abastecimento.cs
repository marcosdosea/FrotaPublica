using System;
using System.Collections.Generic;

namespace Core;

public partial class Abastecimento
{
    public uint Id { get; set; }

    public uint IdFornecedor { get; set; }

    public uint IdPercurso { get; set; }

    public DateTime DataHora { get; set; }

    public int Odometro { get; set; }

    public int Litros { get; set; }

    public virtual Fornecedor IdFornecedorNavigation { get; set; } = null!;

    public virtual Percurso IdPercursoNavigation { get; set; } = null!;
}
