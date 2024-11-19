using System.ComponentModel.DataAnnotations;
using System.ComponentModel;

namespace FrotaWeb.Models
{
    public class ManutencaoPecaInsumoViewModel
    {
		[Key]
		[DisplayName("Código")]
		public uint IdManutencao { get; set; }

		[Required(ErrorMessage = "O {0} é obrigatório")]
		[DisplayName("Código da peça/insumo")]
		public uint IdPecaInsumo { get; set; }

		[Required(ErrorMessage = "O {0} é obrigatório")]
		[DisplayName("Código da marca da peça/insumo")]
		public uint IdMarcaPecaInsumo { get; set; }

		[Required(ErrorMessage = "O {0} é obrigatório")]
		public float Quantidade { get; set; }

		[Required(ErrorMessage = "O {0} é obrigatório")]
		[Range(0, 99999999999, ErrorMessage = "A {0} deve ser um número positivo com no máximo 11 dígitos")]
		[DisplayName("Garantia (meses)")]
		public int MesesGarantia { get; set; }

		[Required(ErrorMessage = "O {0} é obrigatório")]
		[Range(0, 99999999999, ErrorMessage = "A {0} deve ser um número positivo com no máximo 11 dígitos")]
		[DisplayName("Garantia (Km)")]
		public int KmGarantia { get; set; }

		[Required(ErrorMessage = "O {0} é obrigatório")]
		[DisplayName("Valor)")]
		public decimal ValorIndividual { get; set; }

		[Required(ErrorMessage = "O {0} é obrigatório")]
		public decimal Subtotal { get; set; }
	}
}
