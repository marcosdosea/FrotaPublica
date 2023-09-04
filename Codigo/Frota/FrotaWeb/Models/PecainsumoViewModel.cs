using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class PecainsumoViewModel
    {
        [Display( Name = "Código")]
        [Key]
        [Required(ErrorMessage = "Código obrigatório")]
        public int Id { get; set; }




    }
}
