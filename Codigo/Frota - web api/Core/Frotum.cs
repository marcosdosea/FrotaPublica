using System;
using System.Collections.Generic;

namespace Core;

public partial class Frotum
{
    public uint Id { get; set; }

    public string Nome { get; set; } = null!;

    public string Cnpj { get; set; } = null!;

    public string? Cep { get; set; }

    public string? Rua { get; set; }

    public string? Bairro { get; set; }

    public string? Numero { get; set; }

    public string? Complemento { get; set; }

    public string? Cidade { get; set; }

    public string Estado { get; set; } = null!;

    public virtual ICollection<Abastecimento> Abastecimentos { get; set; } = new List<Abastecimento>();

    public virtual ICollection<Fornecedor> Fornecedors { get; set; } = new List<Fornecedor>();

    public virtual ICollection<Manutencao> Manutencaos { get; set; } = new List<Manutencao>();

    public virtual ICollection<Marcapecainsumo> Marcapecainsumos { get; set; } = new List<Marcapecainsumo>();

    public virtual ICollection<Marcaveiculo> Marcaveiculos { get; set; } = new List<Marcaveiculo>();

    public virtual ICollection<Modeloveiculo> Modeloveiculos { get; set; } = new List<Modeloveiculo>();

    public virtual ICollection<Pecainsumo> Pecainsumos { get; set; } = new List<Pecainsumo>();

    public virtual ICollection<Pessoa> Pessoas { get; set; } = new List<Pessoa>();

    public virtual ICollection<Solicitacaomanutencao> Solicitacaomanutencaos { get; set; } = new List<Solicitacaomanutencao>();

    public virtual ICollection<Unidadeadministrativa> Unidadeadministrativas { get; set; } = new List<Unidadeadministrativa>();

    public virtual ICollection<Veiculo> Veiculos { get; set; } = new List<Veiculo>();
}
