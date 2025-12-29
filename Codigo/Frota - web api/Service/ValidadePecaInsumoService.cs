using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service
{
    public class ValidadePecaInsumoService : IValidadePecaInsumoService
    {
        private readonly FrotaContext context;
        private readonly IVeiculoService veiculoService;
        private readonly IPecaInsumoService pecaInsumoService;

        public ValidadePecaInsumoService(FrotaContext context, IVeiculoService veiculoService, IPecaInsumoService pecaInsumoService)
        {
            this.context = context;
            this.veiculoService = veiculoService;
            this.pecaInsumoService = pecaInsumoService;
        }

        public void AtualizarValidadeAposManutencao(uint idManutencao, uint idVeiculo)
        {
            var manutencao = context.Manutencaos
                .Include(m => m.Manutencaopecainsumos)
                .ThenInclude(mp => mp.IdPecaInsumoNavigation)
                .FirstOrDefault(m => m.Id == idManutencao);

            if (manutencao == null) return;

            var veiculo = veiculoService.Get(idVeiculo);
            if (veiculo == null) return;

            foreach (var manutencaoPeca in manutencao.Manutencaopecainsumos)
            {
                var peca = manutencaoPeca.IdPecaInsumoNavigation;
                var dataManutencao = manutencao.DataHora;
                var odometroManutencao = veiculo.Odometro;

                // Calcular datas e km de validade
                var dataFinalGarantia = dataManutencao.AddMonths(peca.MesesGarantia);
                var kmFinalGarantia = odometroManutencao + peca.KmGarantia;
                var dataProximaTroca = dataManutencao.AddMonths(manutencaoPeca.MesesGarantia);
                var kmProximaTroca = odometroManutencao + manutencaoPeca.KmGarantia;

                // Verificar se já existe registro para esta peça neste veículo
                var veiculoPeca = context.Veiculopecainsumos
                    .FirstOrDefault(vp => vp.IdVeiculo == idVeiculo && vp.IdPecaInsumo == peca.Id);

                if (veiculoPeca == null)
                {
                    // Criar novo registro
                    veiculoPeca = new Veiculopecainsumo
                    {
                        IdVeiculo = idVeiculo,
                        IdPecaInsumo = peca.Id,
                        DataFinalGarantia = dataFinalGarantia,
                        KmFinalGarantia = kmFinalGarantia,
                        DataProximaTroca = dataProximaTroca,
                        KmProximaTroca = kmProximaTroca
                    };
                    context.Veiculopecainsumos.Add(veiculoPeca);
                }
                else
                {
                    // Atualizar registro existente (nova manutenção = resetar contadores)
                    veiculoPeca.DataFinalGarantia = dataFinalGarantia;
                    veiculoPeca.KmFinalGarantia = kmFinalGarantia;
                    veiculoPeca.DataProximaTroca = dataProximaTroca;
                    veiculoPeca.KmProximaTroca = kmProximaTroca;
                    context.Veiculopecainsumos.Update(veiculoPeca);
                }
            }

            context.SaveChanges();
        }

        public IEnumerable<AlertaValidade> ObterAlertasVeiculo(uint idVeiculo)
        {
            var veiculo = veiculoService.Get(idVeiculo);
            if (veiculo == null) return Enumerable.Empty<AlertaValidade>();

            var veiculoPecas = context.Veiculopecainsumos
                .Include(vp => vp.IdPecaInsumoNavigation)
                .Where(vp => vp.IdVeiculo == idVeiculo)
                .ToList();

            return GerarAlertas(veiculoPecas, veiculo);
        }

        public IEnumerable<AlertaValidade> ObterAlertasFrota(uint idFrota)
        {
            var veiculos = context.Veiculos
                .Where(v => v.IdFrota == idFrota)
                .ToList();

            var alertas = new List<AlertaValidade>();

            foreach (var veiculo in veiculos)
            {
                var veiculoPecas = context.Veiculopecainsumos
                    .Include(vp => vp.IdPecaInsumoNavigation)
                    .Where(vp => vp.IdVeiculo == veiculo.Id)
                    .ToList();

                alertas.AddRange(GerarAlertas(veiculoPecas, veiculo));
            }

            return alertas.OrderBy(a => a.TipoAlerta == "Urgente" ? 0 : 1)
                          .ThenBy(a => a.KmRestantes)
                          .ThenBy(a => a.DiasRestantes);
        }

        public IEnumerable<AlertaValidade> ObterAlertasUnidadeAdministrativa(uint idUnidade)
        {
            var veiculos = context.Veiculos
                .Where(v => v.IdUnidadeAdministrativa == idUnidade)
                .ToList();

            var alertas = new List<AlertaValidade>();

            foreach (var veiculo in veiculos)
            {
                var veiculoPecas = context.Veiculopecainsumos
                    .Include(vp => vp.IdPecaInsumoNavigation)
                    .Where(vp => vp.IdVeiculo == veiculo.Id)
                    .ToList();

                alertas.AddRange(GerarAlertas(veiculoPecas, veiculo));
            }

            return alertas.OrderBy(a => a.TipoAlerta == "Urgente" ? 0 : 1)
                          .ThenBy(a => a.KmRestantes)
                          .ThenBy(a => a.DiasRestantes);
        }

        public bool EstaProximoVencimento(Veiculopecainsumo veiculoPeca, int odometroAtual)
        {
            var kmRestantes = veiculoPeca.KmProximaTroca - odometroAtual;
            var kmTotal = veiculoPeca.KmProximaTroca - (odometroAtual - (veiculoPeca.KmProximaTroca - veiculoPeca.KmFinalGarantia));
            var percentualUsado = kmTotal > 0 ? (double)(odometroAtual - (veiculoPeca.KmProximaTroca - veiculoPeca.KmFinalGarantia)) / kmTotal : 0;

            var diasRestantes = (veiculoPeca.DataProximaTroca - DateTime.Now).Days;
            var diasTotal = (veiculoPeca.DataProximaTroca - veiculoPeca.DataFinalGarantia.AddMonths(-veiculoPeca.IdPecaInsumoNavigation.MesesGarantia)).Days;
            var percentualTempoUsado = diasTotal > 0 ? (double)(DateTime.Now - veiculoPeca.DataFinalGarantia.AddMonths(-veiculoPeca.IdPecaInsumoNavigation.MesesGarantia)).Days / diasTotal : 0;

            // Considera próximo se está acima de 80% de uso ou se já passou
            return percentualUsado >= 0.8 || percentualTempoUsado >= 0.8 || kmRestantes <= 0 || diasRestantes <= 0;
        }

        private List<AlertaValidade> GerarAlertas(List<Veiculopecainsumo> veiculoPecas, Veiculo veiculo)
        {
            var alertas = new List<AlertaValidade>();
            var odometroAtual = veiculo.Odometro;
            var hoje = DateTime.Now;

            foreach (var veiculoPeca in veiculoPecas)
            {
                var kmRestantes = veiculoPeca.KmProximaTroca - odometroAtual;
                var diasRestantes = (veiculoPeca.DataProximaTroca - hoje).Days;

                // Verificar se precisa de alerta
                bool precisaAlerta = false;
                string tipoAlerta = "Aviso";
                string mensagem = "";

                // Verificar por quilometragem
                if (kmRestantes <= 0)
                {
                    precisaAlerta = true;
                    tipoAlerta = "Urgente";
                    mensagem = $"A peça '{veiculoPeca.IdPecaInsumoNavigation.Descricao}' do veículo {veiculo.Placa} já ultrapassou a quilometragem de troca ({veiculoPeca.KmProximaTroca} km). Troca urgente necessária!";
                }
                else if (kmRestantes <= (veiculoPeca.IdPecaInsumoNavigation.KmGarantia * 0.2)) // Últimos 20%
                {
                    precisaAlerta = true;
                    tipoAlerta = "Urgente";
                    mensagem = $"A peça '{veiculoPeca.IdPecaInsumoNavigation.Descricao}' do veículo {veiculo.Placa} está próxima da quilometragem de troca. Restam apenas {kmRestantes} km.";
                }
                else if (kmRestantes <= (veiculoPeca.IdPecaInsumoNavigation.KmGarantia * 0.3)) // Últimos 30%
                {
                    precisaAlerta = true;
                    tipoAlerta = "Aviso";
                    mensagem = $"A peça '{veiculoPeca.IdPecaInsumoNavigation.Descricao}' do veículo {veiculo.Placa} está se aproximando da quilometragem de troca. Restam {kmRestantes} km.";
                }

                // Verificar por tempo
                if (diasRestantes <= 0)
                {
                    precisaAlerta = true;
                    tipoAlerta = "Urgente";
                    mensagem = $"A peça '{veiculoPeca.IdPecaInsumoNavigation.Descricao}' do veículo {veiculo.Placa} já ultrapassou o prazo de troca ({veiculoPeca.DataProximaTroca:dd/MM/yyyy}). Troca urgente necessária!";
                }
                else if (diasRestantes <= 30) // Últimos 30 dias
                {
                    precisaAlerta = true;
                    if (tipoAlerta != "Urgente") tipoAlerta = "Urgente";
                    mensagem = $"A peça '{veiculoPeca.IdPecaInsumoNavigation.Descricao}' do veículo {veiculo.Placa} está próxima do prazo de troca. Restam apenas {diasRestantes} dias.";
                }
                else if (diasRestantes <= 60) // Últimos 60 dias
                {
                    precisaAlerta = true;
                    if (tipoAlerta == "Aviso")
                    {
                        mensagem = $"A peça '{veiculoPeca.IdPecaInsumoNavigation.Descricao}' do veículo {veiculo.Placa} está se aproximando do prazo de troca. Restam {diasRestantes} dias.";
                    }
                }

                if (precisaAlerta)
                {
                    alertas.Add(new AlertaValidade
                    {
                        IdVeiculo = veiculo.Id,
                        PlacaVeiculo = veiculo.Placa,
                        IdPecaInsumo = veiculoPeca.IdPecaInsumo,
                        DescricaoPeca = veiculoPeca.IdPecaInsumoNavigation.Descricao,
                        DataProximaTroca = veiculoPeca.DataProximaTroca,
                        KmProximaTroca = veiculoPeca.KmProximaTroca,
                        OdometroAtual = odometroAtual,
                        KmRestantes = kmRestantes,
                        DiasRestantes = diasRestantes,
                        TipoAlerta = tipoAlerta,
                        Mensagem = mensagem
                    });
                }
            }

            return alertas;
        }
    }
}

