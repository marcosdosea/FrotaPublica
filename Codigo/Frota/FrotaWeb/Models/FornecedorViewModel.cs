using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class FornecedorViewModel
    {
        [Required]
        public uint Id { get; set; }
        [Required]
        [StringLength(50)]
        public string Nome { get; set; } = null!;
        [Required]
        public string Cnpj { get; set; } = null!;

        public string? Cep { get; set; }

        public string? Rua { get; set; }

        public string? Bairro { get; set; }

        public string? Numero { get; set; }

        public string? Complemento { get; set; }

        public string? Cidade { get; set; }

        public string? Estado { get; set; } = null!;

        public int? Latitude { get; set; }

        public int? Longitude { get; set; }
    }
}
