using System.ComponentModel.DataAnnotations;
using System.ComponentModel;

namespace FrotaWeb.Models
{
	public class PercursoViewModel
	{
		public uint Id { get; set; }

		[Required(ErrorMessage = "O {0} é obrigatório")]
		[DisplayName("Código do veículo")]
		public uint IdVeiculo { get; set; }

		[Required(ErrorMessage = "O {0} é obrigatório")]
		[DisplayName("Código do motorista")]
		public uint IdPessoa { get; set; }

		[DataType(DataType.DateTime)]
		[Required(ErrorMessage = "A {0} é obrigatória")]
		[DisplayName("Data e hora da saída")]
		public DateTime DataHoraSaida { get; set; }

		[DataType(DataType.DateTime)]
		[Required(ErrorMessage = "A {0} é obrigatória")]
		[DisplayName("Data e hora do retorno")]
		public DateTime DataHoraRetorno { get; set; }

		[Required(ErrorMessage = "O {0} é obrigatório")]
		[MaxLength(50)]
		[DisplayName("Local de partida")]
		public string LocalPartida { get; set; } = null!;

		public float? LatitudePartida { get; set; }

		public float? LongitudePartida { get; set; }

		[Required(ErrorMessage = "O {0} é obrigatório")]
		[MaxLength(50)]
		[DisplayName("Local de chegada")]
		public string LocalChegada { get; set; } = null!;

		public float? LatitudeChegada { get; set; }

		public float? LongitudeChegada { get; set; }

		[Required(ErrorMessage = "A {0} é obrigatório")]
		[DisplayName("leitura inicial do odômetro")]
		public int OdometroInicial { get; set; }

		[Required(ErrorMessage = "A {0} é obrigatório")]
		[DisplayName("leitura final do odômetro")]
		public int OdometroFinal { get; set; }

		[Required(ErrorMessage = "O {0} é obrigatório")]
		[MaxLength(300)]
		[DisplayName("Motivo")]
		public string? Motivo { get; set; }
	}
}
