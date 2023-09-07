using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models;

public class SolicitacaomanutencaoViewModel
{
    [Required]
    [Display(Name = "Código do veículo")]
    public uint IdVeiculo { get; set; }

    [Required]
    [Display(Name = "Código do requerente da manutenção")]
    public uint IdPessoa { get; set; }

    [Required]
    [Display(Name = "Data da solicitação")]
    [DataType(DataType.DateTime)]
    public DateTime DataSolicitacao { get; set; }

    [Required]
    [Display(Name = "Descrição do problema")]
    [StringLength(maximumLength: 500)]
    public string DescricaoProblema { get; set; } = null!;
}

