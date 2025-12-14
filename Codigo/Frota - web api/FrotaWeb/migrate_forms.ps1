# Script para migrar formulários para o padrão moderno
# Executar no diretório raiz do projeto

$formFiles = @(
    "Views/Frota/Edit.cshtml",
    "Views/Frota/Delete.cshtml",
    "Views/Percurso/Create.cshtml",
    "Views/Percurso/Edit.cshtml", 
    "Views/Percurso/Delete.cshtml",
    "Views/Vistoria/Create.cshtml",
    "Views/Vistoria/Edit.cshtml",
    "Views/Vistoria/Delete.cshtml",
    "Views/Manutencao/Create.cshtml",
    "Views/Manutencao/Edit.cshtml",
    "Views/Manutencao/Delete.cshtml",
    "Views/PecaInsumo/Create.cshtml",
    "Views/PecaInsumo/Edit.cshtml",
    "Views/PecaInsumo/Delete.cshtml",
    "Views/MarcaVeiculo/Create.cshtml",
    "Views/MarcaVeiculo/Edit.cshtml",
    "Views/MarcaVeiculo/Delete.cshtml",
    "Views/ModeloVeiculo/Create.cshtml",
    "Views/ModeloVeiculo/Edit.cshtml",
    "Views/ModeloVeiculo/Delete.cshtml",
    "Views/UnidadeAdministrativa/Create.cshtml",
    "Views/UnidadeAdministrativa/Edit.cshtml",
    "Views/UnidadeAdministrativa/Delete.cshtml",
    "Views/Abastecimento/Create.cshtml",
    "Views/Abastecimento/Edit.cshtml",
    "Views/Abastecimento/Delete.cshtml",
    "Views/SolicitacaoManutencao/Create.cshtml",
    "Views/SolicitacaoManutencao/Edit.cshtml",
    "Views/SolicitacaoManutencao/Delete.cshtml",
    "Views/VeiculoPecaInsumo/Create.cshtml",
    "Views/VeiculoPecaInsumo/Edit.cshtml",
    "Views/VeiculoPecaInsumo/Delete.cshtml",
    "Views/MarcaPecaInsumo/Create.cshtml",
    "Views/MarcaPecaInsumo/Edit.cshtml",
    "Views/MarcaPecaInsumo/Delete.cshtml",
    "Views/ManutencaoPecaInsumo/Create.cshtml",
    "Views/ManutencaoPecaInsumo/Edit.cshtml",
    "Views/ManutencaoPecaInsumo/Delete.cshtml"
)

foreach ($file in $formFiles) {
    if (Test-Path $file) {
        Write-Host "Migrando $file..."
        # Aqui você pode adicionar a lógica de migração
    }
}

Write-Host "Migração concluída!"
