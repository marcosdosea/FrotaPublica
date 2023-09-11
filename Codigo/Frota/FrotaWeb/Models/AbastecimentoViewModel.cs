using Core;
using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class AbastecimentoViewModel
    {
        [Key]
        [Required]
        public uint Id { get; set; }

        [Required]
        [Display(Name = "Leitura do Odômetro")]
        public int Odometro { get; set; }

        [Required]
        [Display(Name = "Litros Abastecidos")]
        public int Litros { get; set; }

        [Required]
        [Display(Name = "Data e hora do Abastecimento")]
        public DateTime DataHora { get; set; }

        [Required]
        [Display(Name = "Fornecedor")]
        public virtual Fornecedor IdFornecedorNavigation { get; set; } = null!;

        [Required]
        [Display(Name = "Percurso")]
        public virtual Percurso IdNavigation { get; set; } = null!;

    }
}
