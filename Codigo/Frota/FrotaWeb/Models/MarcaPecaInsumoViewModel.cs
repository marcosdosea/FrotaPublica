using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class MarcaPecaInsumoViewModel
    {
        [Display(Name = "Código")]
        [Required]
        public uint Id { get; set; }

        [Required]
        [StringLength(50)]
        public string Descricao { get; set; } = null!;
    }
}
