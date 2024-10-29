using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FrotaWeb.Models
{
    public class VeiculoViewModel
    {

        [Key]
        [DisplayName("Código")]
        public uint Id { get; set; }

        [Required(ErrorMessage = "A {0} é obrigatória")]
        [StringLength(10, ErrorMessage = "A {0} pode ter no máximo 10 caracteres")]
        public string Placa { get; set; } = null!;

        [StringLength(50, ErrorMessage = "O {0} pode ter no máximo 50 caracteres")]
        public string? Chassi { get; set; }

        [Required(ErrorMessage = "A {0} é obrigatório")]
        [StringLength(50, ErrorMessage = "A {0} pode ter no máximo 50 caracteres")]
        public string Cor { get; set; } = null!;

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Código do Modelo")]
        public uint IdModeloVeiculo { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Código da Frota")]
        public uint IdFrota { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Código da Unidade Administrativa")]
        public uint IdUnidadeAdministrativa { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Odômetro")]
        public int Odometro { get; set; } = 0;

        [Required(ErrorMessage = "O {0} é obrigatório")]
        public string Status { get; set; } = null!;

        [Required(ErrorMessage = "O {0} é obrigatório")]
        public int Ano { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        public int Modelo { get; set; }

        [StringLength(50, ErrorMessage = "O {0} pode ter no máximo 50 caracteres")]
        public string? Renavan { get; set; }

        [DataType(DataType.DateTime)]
        public DateTime? VencimentoIpva { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [Range(0, 99999999.99, ErrorMessage = "O {0} deve estar entre 0 e 99.999.999,99.")]
        public decimal Valor { get; set; }

        [Required(ErrorMessage = "A {0} é obrigatório")]
        [DisplayName("Data de Referência")]
        [DataType(DataType.DateTime)]
        public DateTime DataReferenciaValor { get; set; }

    }
}