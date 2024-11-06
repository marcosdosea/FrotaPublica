using Core;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using Util;


namespace FrotaWeb.Models
{
    public class FornecedorViewModel
    {

        [Key]
        [DisplayName("Código")]
        public uint Id { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [StringLength(50, ErrorMessage = "O {0} pode ter no máximo 50 caracteres")]
        public string Nome { get; set; } = null!;

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [StringLength(14, MinimumLength = 14, ErrorMessage = "O {0} deve possuir 14 dígitos")]
        public string Cnpj { get; set; } = null!;

        [Cep]
        [StringLength(8, MinimumLength = 8, ErrorMessage = "O {0} deve possuir 8 dígitos")]
        public string? Cep { get; set; }

        [StringLength(50, ErrorMessage = "A {0} pode ter no máximo 50 caracteres")]
        public string? Rua { get; set; }

        [StringLength(50, ErrorMessage = "O {0} pode ter no máximo 50 caracteres")]
        public string? Bairro { get; set; }
         
        [StringLength(50, ErrorMessage = "O {0} pode ter no máximo 10 caracteres")]
        [DisplayName("Número")]
        public string? Numero { get; set; }

        [StringLength(50, ErrorMessage = "O {0} pode ter no máximo 50 caracteres")]
        public string? Complemento { get; set; }

        [StringLength(50, ErrorMessage = "A {0} pode possuir no máximo 50 caracteres")]
        public string? Cidade { get; set; }

        [StringLength(2, MinimumLength = 2, ErrorMessage = "A sigla do {0} deve possuir 2 caracteres")]
        public string? Estado { get; set; } = null!;

        public int? Latitude { get; set; }

        public int? Longitude { get; set; }

    }
}
