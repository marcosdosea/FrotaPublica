using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using Core;

namespace FrotaWeb.Models
{
    public class ManutencaoViewModel
    {

        [Key]
        [DisplayName("Código")]
        public uint Id { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Código do Veículo")]
        public uint IdVeiculo { get; set; }
        public string? PlacaVeiculo { get; set; } = string.Empty;

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Código do Fornecedor")]
        public uint IdFornecedor { get; set; }

        [DataType(DataType.DateTime)]
        [Required(ErrorMessage = "A {0} é obrigatório")]
        [DisplayName("Data da Manutenção")]
        public DateTime DataHora { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Código do Responsável")]
        public uint IdResponsavel { get; set; }
        public string? NomeResponsavel { get; set; } = string.Empty;

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Valor das Peças")]
        [RegularExpression(@"^\d{1,8}([.,]\d{1,2})?$", ErrorMessage = "O {0} deve estar ente 0 e 99.999.999,99")]
        public string ValorPecas { get; set; } = "0.00";

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Valor da Manutenção")]
        [RegularExpression(@"^\d{1,8}([.,]\d{1,2})?$", ErrorMessage = "O {0} deve estar ente 0 e 99.999.999,99")]
        public string ValorManutencao { get; set; } = string.Empty;

        [Required(ErrorMessage = "O {0} é obrigatório")]
        public string Tipo { get; set; } = null!;

        public byte[]? Comprovante { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        public string Status { get; set; } = null!;

        public uint IdFrota { get; set; }
    }
}
