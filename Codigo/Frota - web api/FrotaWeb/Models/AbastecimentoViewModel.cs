using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class AbastecimentoViewModel
    {

        [Key]
        [DisplayName("Código")]
        public uint Id { get; set; }

		[Required(ErrorMessage = "O {0} é obrigatório")]
		[DisplayName("Código do fornecedor")]
		public uint IdFornecedor { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Código do Veículo")]
        public uint IdVeiculo { get; set; }

        public uint IdFrota { get; set; }

        public uint IdPessoa { get; set; }

        [DataType(DataType.DateTime)]
        [Required(ErrorMessage = "A {0} é obrigatória")]
        [DisplayName("Data do abastecimento")]
        public DateTime DataHora { get; set; }

        [Required(ErrorMessage = "A {0} é obrigatória")]
        [DisplayName("Leitura do odômetro")]
        [RegularExpression(@"^(?:\d{1,6}|1000000)$", ErrorMessage = "A {0} deve ser um número entre 0 e 1.000.000.")]
        public string Odometro { get; set; } = "0";

        [Required(ErrorMessage = "Os {0} são obrigatórios")]
        [DisplayName("Litros Abastecidos")]
        [RegularExpression(@"^\d{1,8}([.,]\d{1,2})?$", ErrorMessage = "O {0} deve estar ente 0 e 99.999.999,99")]
        public string Litros { get; set; } = "0";
    }
}
