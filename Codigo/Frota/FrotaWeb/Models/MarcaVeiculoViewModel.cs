using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class MarcaVeiculoViewModel
    {
        [DisplayName("Código da Marca")]
        [Required(ErrorMessage = "O Código da marca é necessário")]
        [Key]
        public int Id { get; set; }

        [DisplayName("Nome da Marca")]
        [Required(ErrorMessage = "O nome da marca é necessário")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "O nome da marca deve ter no mínimo 2 caracteres")]
        public string Nome { get; set; }
    }
}
