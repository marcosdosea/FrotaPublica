using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class VeiculoViewModel
    {
        [Required]
        public uint Id { get; set; }

        [Required]
        [StringLength(maximumLength: 10)]
        public string Placa { get; set; } = null!;

        [Required]
        [StringLength(maximumLength: 50)]
        public string? Chassi { get; set; }

        [StringLength(maximumLength: 50)]
        public string Cor { get; set; } = null!;

        [Required]
        public uint IdModeloVeiculo { get; set; }

        [Required]
        public uint IdFrota { get; set; }

        [Required]
        public uint IdUnidadeAdministrativa { get; set; }

        public int Odometro { get; set; } = 0;

        public string Status { get; set; } = null!;

        public int Ano { get; set; }

        [Required]
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

