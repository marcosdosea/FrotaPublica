using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace FrotaApi.Models;

public class SolicitacaoManutencaoViewModel
{

    [Key]
    [DisplayName("Código")]
    public uint Id { get; set; }

    [Required(ErrorMessage = "O {0} é obrigatório")]
    [DisplayName("Código do Veículo")]
    public uint IdVeiculo { get; set; }

    [Required(ErrorMessage = "O {0} é obrigatório")]
    [DisplayName("Código da Pessoa")]
    public uint IdPessoa { get; set; }

    [Required(ErrorMessage = "A {0} é obrigatório")]
    [DisplayName("Data da Solicitação")]
    [DataType(DataType.DateTime)]
    public DateTime DataSolicitacao { get; set; }

    [Required(ErrorMessage = "A {0} é obrigatório")]
    [DisplayName("Descrição")]
    [StringLength(500, ErrorMessage = "A {0} pode ter no máximo 500 caracteres")]
    public string DescricaoProblema { get; set; } = null!;

}

