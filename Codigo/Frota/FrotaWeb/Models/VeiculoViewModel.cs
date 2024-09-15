using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class VeiculoViewModel
    {
        [Key]		
		public uint Id { get; set; }

		[Required(ErrorMessage = "O campo Placa é obrigatório.")]
		[StringLength(maximumLength: 10)]
        public string Placa { get; set; } = null!;

		[Required(ErrorMessage = "O campo Chassi é obrigatório.")]
		[StringLength(maximumLength: 50)]
        public string? Chassi { get; set; }

		[Required(ErrorMessage = "O campo Cor é obrigatório.")]
		[StringLength(maximumLength: 50)]
        public string Cor { get; set; } = null!;

		[Required(ErrorMessage = "O campo IdModeloVeiculo é obrigatório.")]
        public uint IdModeloVeiculo { get; set; }

        [Required(ErrorMessage = "O campo IdFrota é obrigatório.")]
        public uint IdFrota { get; set; }

		[Required(ErrorMessage = "O campo IdUnidadeAdministrativa é obrigatório.")]
		public uint IdUnidadeAdministrativa { get; set; }

        public int Odometro { get; set; } = 0;

        public string Status { get; set; } = null!;

        public int Ano { get; set; }

		[Required(ErrorMessage = "O campo Modelo é obrigatório.")]
		public int Modelo { get; set; }

        [StringLength(maximumLength: 50)]
        public string? Renavan { get; set; }

        [DataType(DataType.DateTime)]
        public DateTime? VencimentoIpva { get; set; }

        public decimal Valor { get; set; }

        [DataType(DataType.DateTime)]
        public DateTime DataReferenciaValor { get; set; }
    }
}

