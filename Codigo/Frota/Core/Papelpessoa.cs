namespace Core;

public partial class Papelpessoa
{
    public uint Id { get; set; }

    public string Papel { get; set; } = null!;

    public virtual ICollection<Pessoa> Pessoas { get; set; } = new List<Pessoa>();
}
