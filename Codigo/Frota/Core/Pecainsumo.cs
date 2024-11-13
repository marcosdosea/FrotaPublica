namespace Core;

public partial class Pecainsumo
{
    public uint Id { get; set; }

    public string Descricao { get; set; } = null!;

    public virtual ICollection<Manutencaopecainsumo> Manutencaopecainsumos { get; set; } = new List<Manutencaopecainsumo>();

    public virtual ICollection<Veiculopecainsumo> Veiculopecainsumos { get; set; } = new List<Veiculopecainsumo>();
}
