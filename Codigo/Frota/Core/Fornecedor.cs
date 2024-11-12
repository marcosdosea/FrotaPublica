namespace Core;

public partial class Fornecedor
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

    public string? Estado { get; set; }

    public int? Latitude { get; set; }

    public int? Longitude { get; set; }

    public virtual ICollection<Abastecimento> Abastecimentos { get; set; } = new List<Abastecimento>();

    public virtual ICollection<Manutencao> Manutencaos { get; set; } = new List<Manutencao>();
}
