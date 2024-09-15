using Core;
using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class PessoaViewModel
    {
		[Key]
        [Display(Name = "Código")]
		public uint Id { get; set; }

        [Required(ErrorMessage = "Campo requerido")]
        [StringLength(11, MinimumLength = 11 ,ErrorMessage = "Cpf deve possuir 11 dígitos")]
        public string Cpf { get; set; } = null!;

        [Required(ErrorMessage = "Campo requerido")]
        [StringLength(50, MinimumLength = 5, ErrorMessage = "O nome deve ter entre 5 e 50 caracteres")]
        public string Nome { get; set; } = null!;

        [StringLength(8, MinimumLength = 8, ErrorMessage = "Cep deve possuir 8 dígitos")]
        public string? Cep { get; set; }

        [StringLength(50, ErrorMessage = "O nome da rua deve possuir no máximo 50 caracteres")]
        public string? Rua { get; set; }

        [StringLength(50, ErrorMessage = "O nome do bairro deve possuir no máximo 50 caracteres")]
        public string? Bairro { get; set; }

        [StringLength(50, ErrorMessage = "O complemento deve possuir no máximo 50 caracteres")]
        public string? Complemento { get; set; }

        [StringLength(10, ErrorMessage = "O número deve possuir no máximo 10 caracteres")]
        public string? Numero { get; set; }

        [StringLength(50, ErrorMessage = "O nome da cidade deve possuir no máximo 50 caracteres")]
        public string? Cidade { get; set; }

        [Required(ErrorMessage = "Campo requerido")]
        [StringLength(2, MinimumLength = 2,ErrorMessage = "O nome do estado deve possuir 2 caracteres")]
        public string Estado { get; set; } = null!;

        [Display(Name = "Código/Frota")]
        [Required(ErrorMessage = "Código da frota é obrigatório")]
        public uint IdFrota { get; set; }

        [Display(Name = "Código/Cargo")]
        [Required(ErrorMessage = "Código da frota é obrigatório")]
        public uint IdPapelPessoa { get; set; }

        [Required(ErrorMessage = "Campo obrigatório")]
        public sbyte Ativo { get; set; }

        public virtual Frota IdFrotaNavigation { get; set; } = null!;

        public virtual Papelpessoa IdPapelPessoaNavigation { get; set; } = null!;

        public virtual ICollection<Manutencao> Manutencaos { get; set; } = new List<Manutencao>();

        public virtual ICollection<Percurso> Percursos { get; set; } = new List<Percurso>();

        public virtual ICollection<Solicitacaomanutencao> Solicitacaomanutencaos { get; set; } = new List<Solicitacaomanutencao>();

        public virtual ICollection<Vistorium> Vistoria { get; set; } = new List<Vistorium>();
    }
}
