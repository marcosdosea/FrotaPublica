using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class PecaInsumoViewModel
    {
		[Key]
        [Display(Name = "Código")]
		public int Id { get; set; }
             

        [StringLength(50)]
        public string? Descricao { get; set; }

    }
}
