using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
    public class VistoriaViewModel
    {

        [Key]
        [DisplayName("Código")]
        public int Id { get; set; }

        [Required(ErrorMessage = "A {0} é obrigatório")]
        [DisplayName("Data da Vistoria")]
        [DataType(DataType.DateTime)]
        public DateTime Data { get; set; }

        [Required(ErrorMessage = "A {0} é obrigatória.")]
        [StringLength(500, ErrorMessage = "A {0} pode ter no máximo 50 caracteres")]
        [DisplayName("descrição dos problemas")]
        public string Problemas { get; set; } = null!;

        [Required(ErrorMessage = "O {0} é obrigatório")]
        public string Tipo { get; set; } = null!;

        [Required(ErrorMessage = "O {0} é obrigatório")]
        [DisplayName("Código do responsável")]
        public uint IdPessoaResponsavel { get; set; }

    }
}
