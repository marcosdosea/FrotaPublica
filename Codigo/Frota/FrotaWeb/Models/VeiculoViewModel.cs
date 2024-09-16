using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FrotaWeb.Models
{
	public class VeiculoViewModel
	{
		[Key]
		public uint Id { get; set; }

		[Required(ErrorMessage = "O campo Placa é obrigatório.")]
		[StringLength(maximumLength: 10)]
		public string Placa { get; set; } = null!;

		[StringLength(maximumLength: 50)]
		public string? Chassi { get; set; }

		[Required(ErrorMessage = "O campo Cor é obrigatório.")]
		[StringLength(maximumLength: 50)]
		public string Cor { get; set; } = null!;

		[Required(ErrorMessage = "O campo ModeloVeiculo é obrigatório.")]
		[ForeignKey("ModeloVeiculo")]
		public uint IdModeloVeiculo { get; set; }

        [Required(ErrorMessage = "O campo Frota é obrigatório.")]
        [ForeignKey("Frota")]
		public uint IdFrota { get; set; }

        [Required(ErrorMessage = "O campo UnidadeAdministrativa é obrigatório.")]
        [ForeignKey("UnidadeAdministrativa")]
		public uint IdUnidadeAdministrativa { get; set; }

		[Required(ErrorMessage = "O campo Odómetro é obrigatório.")]
		public int Odometro { get; set; } = 0;

		[Required(ErrorMessage = "O campo Status é obrigatório.")]
		public string Status { get; set; } = null!;

		[Required(ErrorMessage = "O campo Ano é obrigatório.")]
		public int Ano { get; set; }


		[StringLength(maximumLength: 50)]
		public string? Renavan { get; set; }

		[DataType(DataType.DateTime)]
		public DateTime? VencimentoIpva { get; set; }

		[Required(ErrorMessage = "O campo Valor é obrigatório.")]
		public decimal Valor { get; set; }

		[Required(ErrorMessage = "O campo Data Referência é obrigatório.")]
		[DataType(DataType.DateTime)]
		public DateTime DataReferenciaValor { get; set; }

		[Required(ErrorMessage = "O campo Modelo é obrigatório.")]
		public int Modelo { get; set; }
	}
}