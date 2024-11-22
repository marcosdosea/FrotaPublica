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
        [DisplayName("Código do percurso")]
        public uint IdPercurso { get; set; }

		[Required(ErrorMessage = "O {0} é obrigatório")]
		[DisplayName("Código do fornecedor")]
		public uint IdFornecedor { get; set; }

		[DataType(DataType.DateTime)]
        [Required(ErrorMessage = "A {0} é obrigatória")]
        [DisplayName("Data do abastecimento")]
        public DateTime DataHora { get; set; }

        [Required(ErrorMessage = "A {0} é obrigatória")]
        [DisplayName("Leitura do odômetro")]
        public int Odometro { get; set; }

        [Required(ErrorMessage = "Os {0} são obrigatórios")]
        [DisplayName("Litros Abastecidos")]
        public int Litros { get; set; }
    }
}
