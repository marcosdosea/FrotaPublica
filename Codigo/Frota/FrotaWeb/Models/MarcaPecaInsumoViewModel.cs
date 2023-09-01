using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class MarcaPecaInsumoViewModel
    {
        [Required]
        [Display(Name = "Código")]
        public uint Id { get; set; }

        [Required]
        [Display(Name = "Descrição")]
        [StringLength(50)]
        public string Descricao { get; set; } = null!;
    }
}
