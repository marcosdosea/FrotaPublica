using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class ModeloVeiculoViewModel
    {

        [DisplayName("Código")]
        [Required(ErrorMessage = "O Código do veiculo é necessario")]
        [Key]
        public int Id { get; set; }


        [DisplayName("Código da Marca do Veiculo")]
        [Required(ErrorMessage = "Código da marca é necessaria")]
        public int IdMarca { get; set; }

        [DisplayName("Modelo do Veiculo")]
        [Required(ErrorMessage ="O modelo do veiculo é necessário")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "O nome do modelo deve ter o minimo de 2 caracteres")]
        public string NomeModeloVeiculo { get; set; }

        [DisplayName("Capacidade do tanque de combustivel")]
        public int CapacidadeTanqueCombustivel { get; set; }

    }
}
