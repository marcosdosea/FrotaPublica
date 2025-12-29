using Core;

namespace Core.Service
{
    public interface IValidadePecaInsumoService
    {
        /// <summary>
        /// Atualiza o registro de validade de peça/insumo no veículo quando uma manutenção é realizada
        /// </summary>
        void AtualizarValidadeAposManutencao(uint idManutencao, uint idVeiculo);
        
        /// <summary>
        /// Verifica e retorna alertas de validade para um veículo específico
        /// </summary>
        IEnumerable<AlertaValidade> ObterAlertasVeiculo(uint idVeiculo);
        
        /// <summary>
        /// Verifica e retorna alertas de validade para uma frota
        /// </summary>
        IEnumerable<AlertaValidade> ObterAlertasFrota(uint idFrota);
        
        /// <summary>
        /// Verifica e retorna alertas de validade para uma unidade administrativa
        /// </summary>
        IEnumerable<AlertaValidade> ObterAlertasUnidadeAdministrativa(uint idUnidade);
        
        /// <summary>
        /// Verifica se uma peça está próxima do vencimento (80% da validade)
        /// </summary>
        bool EstaProximoVencimento(Veiculopecainsumo veiculoPeca, int odometroAtual);
    }
    
    public class AlertaValidade
    {
        public uint IdVeiculo { get; set; }
        public string PlacaVeiculo { get; set; } = string.Empty;
        public uint IdPecaInsumo { get; set; }
        public string DescricaoPeca { get; set; } = string.Empty;
        public DateTime DataProximaTroca { get; set; }
        public int KmProximaTroca { get; set; }
        public int OdometroAtual { get; set; }
        public int KmRestantes { get; set; }
        public int DiasRestantes { get; set; }
        public string TipoAlerta { get; set; } = string.Empty; // "Aviso" ou "Urgente"
        public string Mensagem { get; set; } = string.Empty;
    }
}

