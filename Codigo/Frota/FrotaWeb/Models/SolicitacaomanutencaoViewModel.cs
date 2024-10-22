using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models;

public class SolicitacaomanutencaoViewModel
{
    [Key]
    [Display(Name = "Código")]
    [Editable(allowEdit: false)]
    public uint Id { get; set; }

    [Required]
    [Display(Name = "Código do veículo")]
    public uint IdVeiculo { get; set; }

    [Required]
    [Display(Name = "Código da pessoa")]
    public uint IdPessoa { get; set; }

    [Required]
    [Display(Name = "Data da solicitação")]
    [DataType(DataType.DateTime)]
    public DateTime DataSolicitacao { get; set; }

    [Required]
    [Display(Name = "Descrição do problema")]
    [StringLength(maximumLength: 500)]
    public string DescricaoProblema { get; set; }
}

