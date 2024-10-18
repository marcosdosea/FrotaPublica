using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class MarcaVeiculoViewModel
    {
        [Key] 
        public int Id { get; set; }

        [Required(ErrorMessage = "O campo Nome é obrigatório.")]
        public string Nome { get; set; }
    }
}
