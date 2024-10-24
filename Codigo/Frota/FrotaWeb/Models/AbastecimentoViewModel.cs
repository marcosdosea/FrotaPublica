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
        [DisplayName("código do veículo")]
        public uint IdVeiculoPercurso { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("código do pessoa")]
        public uint IdPessoaPercurso { get; set; }

        [DataType(DataType.DateTime)]
        [Required(ErrorMessage = "A {0} é obrigatório")]
        [DisplayName("data do abastecimento")]
        public DateTime DataHora { get; set; }

        [Required(ErrorMessage = "A {0} é obrigatório")]
        [DisplayName("leitura do odômetro")]
        public int Odometro { get; set; }

        [Required(ErrorMessage = "Os {0} é obrigatório")]
        [DisplayName("Litros Abastecidos")]
        public int Litros { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("código do fornecedor")]
        public uint IdFornecedor { get; set; }

    }
}
