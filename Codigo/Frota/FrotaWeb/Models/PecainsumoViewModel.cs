using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class PecainsumoViewModel
    {
        [Display( Name = "Código")]
        [Required(ErrorMessage = "Código obrigatório")]
        public int Id { get; set; }

        [StringLength(50)]
       public string Descricao { get; set; }




    }
}
