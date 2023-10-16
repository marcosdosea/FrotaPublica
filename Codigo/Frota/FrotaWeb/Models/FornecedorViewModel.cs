using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class FornecedorViewModel
    {
        [Display(Name = "Código")]
        [Required(ErrorMessage = "Código da pessoa é obrigatório")]
        public uint Id { get; set; }

        [Required(ErrorMessage = "Campo requerido")]
        [StringLength(50, MinimumLength = 5, ErrorMessage = "O nome deve ter entre 5 e 50 caracteres")]
        [StringLength(50)]
        public string Nome { get; set; } = null!;

        [Required(ErrorMessage = "Campo obrigatório")]
        [StringLength(14, MinimumLength = 14, ErrorMessage = "Cnpj deve possuir 14 dígitos")]
        public string Cnpj { get; set; } = null!;

        [StringLength(8, MinimumLength = 8, ErrorMessage = "Cep deve possuir 8 dígitos")]
        public string? Cep { get; set; }

        [StringLength(50, ErrorMessage = "O nome da rua deve possuir no máximo 50 caracteres")]
        public string? Rua { get; set; }

        [StringLength(50, ErrorMessage = "O nome do bairro deve possuir no máximo 50 caracteres")]
        public string? Bairro { get; set; }

        [StringLength(10, ErrorMessage = "O número deve possuir no máximo 10 caracteres")]
        public string? Numero { get; set; }

        [StringLength(50, ErrorMessage = "O complemento deve possuir no máximo 50 caracteres")]
        public string? Complemento { get; set; }

        [StringLength(50, ErrorMessage = "O nome da cidade deve possuir no máximo 50 caracteres")]
        public string? Cidade { get; set; }

        [Required(ErrorMessage = "Campo requerido")]
        [StringLength(2, MinimumLength = 2, ErrorMessage = "O nome do estado deve possuir 2 caracteres")]
        public string? Estado { get; set; } = null!;

        public int? Latitude { get; set; }

        public int? Longitude { get; set; }

        public virtual ICollection<Abastecimento> Abastecimentos { get; set; } = new List<Abastecimento>();

        public virtual ICollection<Manutencao> Manutencaos { get; set; } = new List<Manutencao>();
    }
}
