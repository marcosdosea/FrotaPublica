using System;

namespace Core;

public partial class Rota
{
    public uint Id { get; set; }

    public uint IdPercurso { get; set; }

    public string RouteJson { get; set; } = null!;

    public DateTime DataCriacao { get; set; }

    public virtual Percurso IdPercursoNavigation { get; set; } = null!;
}

