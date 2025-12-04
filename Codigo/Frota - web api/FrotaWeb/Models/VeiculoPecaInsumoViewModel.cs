using Core;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
	public class VeiculoPecaInsumoViewModel
	{
        [Key]
        [DisplayName("Id Veículo")]
        [Required(ErrorMessage = "A {0} é obrigatório")]
        public uint IdVeiculo { get; set; }

        [Key]
        [DisplayName("Id Peça Insumo")]
        [Required(ErrorMessage = "A {0} é obrigatório")]
        public uint IdPecaInsumo { get; set; }

        [DataType(DataType.DateTime)]
        [DisplayName("Data Final da Garantia")]
        [Required(ErrorMessage = "A {0} é obrigatório")]
        public DateTime DataFinalGarantia { get; set; }

        [DisplayName("Quilometragem Final da Garantia")]
        [Required(ErrorMessage = "O {0} é obrigatório")]
        [Range(0, 99999999.99, ErrorMessage = "O {0} deve estar entre 0 e 99.999.999,99.")]
        public int KmFinalGarantia { get; set; }

        [DataType(DataType.DateTime)]
        [DisplayName("Data da Próxima Troca")]
        [Required(ErrorMessage = "A {0} é obrigatório")]
        public DateTime DataProximaTroca { get; set; }

        [DisplayName("Quilometragem da Próxima Troca")]
        [Required(ErrorMessage = "O {0} é obrigatório")]
        [Range(0, 99999999.99, ErrorMessage = "O {0} deve estar entre 0 e 99.999.999,99.")]
        public int KmProximaTroca { get; set; }
    }
}
