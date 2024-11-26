namespace Core.DTO
{
	public class VeiculoDTO
	{
		public uint Id { get; set; }
		public string Modelo { get; set; }
		public string Cor { get; set; } = null!;
		public string Placa { get; set; } = null!;
		public int Ano { get; set; }
	}
}
