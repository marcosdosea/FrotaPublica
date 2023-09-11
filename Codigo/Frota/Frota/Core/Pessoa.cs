using System;
using System.Collections.Generic;

namespace Core;

public partial class Pessoa
{
    public uint Id { get; set; }

    public string Cpf { get; set; } = null!;

    public string Nome { get; set; } = null!;

    public string? Cep { get; set; }

    public string? Rua { get; set; }

    public string? Bairro { get; set; }

    public string? Complemento { get; set; }

    public string? Numero { get; set; }

    public string? Cidade { get; set; }

    public string Estado { get; set; } = null!;

    public uint IdFrota { get; set; }

    public uint IdPapelPessoa { get; set; }

    public sbyte Ativo { get; set; }

    public virtual Frota IdFrotaNavigation { get; set; } = null!;

    public virtual Papelpessoa IdPapelPessoaNavigation { get; set; } = null!;

    public virtual ICollection<Manutencao> Manutencaos { get; set; } = new List<Manutencao>();

    public virtual ICollection<Percurso> Percursos { get; set; } = new List<Percurso>();

    public virtual ICollection<Solicitacaomanutencao> Solicitacaomanutencaos { get; set; } = new List<Solicitacaomanutencao>();

    public virtual ICollection<Vistorium> Vistoria { get; set; } = new List<Vistorium>();
}
