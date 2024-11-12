namespace Core;

public partial class Modeloveiculo
{
    public uint Id { get; set; }

    public uint IdMarcaVeiculo { get; set; }

    public string Nome { get; set; } = null!;

    public int CapacidadeTanque { get; set; }

    public virtual Marcaveiculo IdMarcaVeiculoNavigation { get; set; } = null!;

    public virtual ICollection<Veiculo> Veiculos { get; set; } = new List<Veiculo>();
}
