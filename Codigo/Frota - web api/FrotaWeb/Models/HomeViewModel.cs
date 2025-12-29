namespace FrotaWeb.Models;

public class HomeViewModel
{
    public string NameUser { get; set; } = string.Empty;
    public string UserType { get; set; } = string.Empty;
    public int CoutLembretes { get; set; }
    public List<string> Lembretes { get; set; } = new List<string>();
    public List<string> Urls { get; set; } = new List<string>();
    
    // Estatísticas para Administrador
    public int TotalFrotas { get; set; }
    public int TotalVeiculos { get; set; }
    public int TotalPessoas { get; set; }
    public int TotalUnidadesAdministrativas { get; set; }
    public int TotalPecasInsumos { get; set; }
    public int TotalMarcasVeiculo { get; set; }
    public int TotalModelosVeiculo { get; set; }
    public int TotalMarcasPecaInsumo { get; set; }
    public int TotalAlertasValidade { get; set; }
    
    // Estatísticas para Gestor
    public int TotalAbastecimentos { get; set; }
    public int TotalManutencoes { get; set; }
    public int TotalVistorias { get; set; }
    public int TotalPercursos { get; set; }
    public int TotalSolicitacoesManutencao { get; set; }
}
