using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class PecaInsumoViewModel
    {

        [Key]
        [DisplayName("Código")]
        public int Id { get; set; }

        [Required(ErrorMessage = "A {0} é obrigatória.")]
        [StringLength(50, ErrorMessage = "A {0} pode ter no máximo 50 caracteres")]
        [DisplayName("Descrição")]
        public string? Descricao { get; set; }

        [Required(ErrorMessage = "A {0} é obrigatória.")]
        [DisplayName("Garantia (Meses)")]
        public int MesesGarantia { get; set; } = 12;

        [Required(ErrorMessage = "A {0} é obrigatória.")]
        [DisplayName("Garantia (Km)")]
        public int KmGarantia { get; set; } = 5000;
    }
}
