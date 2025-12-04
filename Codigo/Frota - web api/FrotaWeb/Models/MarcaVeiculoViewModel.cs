using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class MarcaVeiculoViewModel
    {
        [Key]
        [DisplayName("Código")]
        public int Id { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [StringLength(50, ErrorMessage = "O {0} pode ter no máximo 50 caracteres")]
        public string Nome { get; set; } = null!;
        public uint IdFrota { get; set; }
    }
}
