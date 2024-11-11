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

    }
}
