using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class MarcaPecaInsumoViewModel
    {
        [Key]
        [Display(Name = "Código")]
        public uint Id { get; set; }

        [Required(ErrorMessage = "A descrição é obrigatória.")]
        [Display(Name = "Descrição")]
        [StringLength(50)]
        public string Descricao { get; set; } = null!;
    }
}
