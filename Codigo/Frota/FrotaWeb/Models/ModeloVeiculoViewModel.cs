using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class ModeloVeiculoViewModel
    {

        [Key]
        [DisplayName("Código")]
        public int Id { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Código da Marca")]
        public int IdMarca { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [StringLength(50, ErrorMessage = "O {0} pode ter no máximo 50 caracteres")]
        public string Nome { get; set; } = null!;

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Capacidade do Tanque")]
        [Range(0, int.MaxValue)]
        public int CapacidadeTanqueCombustivel { get; set; }

    }
}
