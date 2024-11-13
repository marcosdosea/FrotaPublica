namespace Core;

public partial class Marcaveiculo
{
    public uint Id { get; set; }

    public string Nome { get; set; } = null!;

    public virtual ICollection<Modeloveiculo> Modeloveiculos { get; set; } = new List<Modeloveiculo>();
}
