using Core;
using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class AbastecimentoViewModel
    {


        [Key]
        public uint Id { get; set; }

        public uint IdVeiculoPercurso { get; set; }

        public uint IdPessoaPercurso { get; set; }

        public DateTime DataHora { get; set; }

        [Required]
        [Display(Name = "Leitura do Odômetro")]
        public int Odometro { get; set; }

        [Required]
        [Display(Name = "Litros Abastecidos")]
        public int Litros { get; set; }

        public uint IdFornecedor { get; set; }

        public virtual Fornecedor IdFornecedorNavigation { get; set; } = null!;

        public virtual Percurso IdNavigation { get; set; } = null!;


        

        
        

    }
}
