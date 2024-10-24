using Util;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class PessoaViewModel
    {

        [Key]
        [DisplayName("Código")]
        public uint Id { get; set; }

        [CPF]
        [Required(ErrorMessage = "O {0} é obrigatório")]
        [StringLength(11, MinimumLength = 11, ErrorMessage = "O {0} deve possuir 11 dígitos")]
        public string Cpf { get; set; } = null!;

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [StringLength(50, ErrorMessage = "O {0} pode ter no máximo 50 caracteres")]
        public string Nome { get; set; } = null!;

        [Cep]
        [StringLength(8, MinimumLength = 8, ErrorMessage = "O {0} deve possuir 8 dígitos")]
        public string? Cep { get; set; }

        [StringLength(50, ErrorMessage = "A {0} pode ter no máximo 50 caracteres")]
        public string? Rua { get; set; }

        [StringLength(50, ErrorMessage = "O {0} pode ter no máximo 50 caracteres")]
        public string? Bairro { get; set; }

        [StringLength(50, ErrorMessage = "O {0} pode ter no máximo 50 caracteres")]
        public string? Complemento { get; set; }

        [StringLength(50, ErrorMessage = "O {0} pode ter no máximo 10 caracteres")]
        [DisplayName("Número")]
        public string? Numero { get; set; }

        [StringLength(50, ErrorMessage = "O nome da {0} pode possuir no máximo 50 caracteres")]
        public string? Cidade { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [StringLength(2, MinimumLength = 2, ErrorMessage = "A sigla do {0} deve possuir 2 caracteres")]
        public string Estado { get; set; } = null!;

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Código da Frota")]
        public uint IdFrota { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Código do Papel Pessoa")]
        public uint IdPapelPessoa { get; set; }

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Campo Ativo")]
        public sbyte Ativo { get; set; }

    }
}
