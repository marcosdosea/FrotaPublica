import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/local_database_service.dart';
import '../services/offline_sync_service.dart';
import '../utils/app_theme.dart';

class OfflineSyncScreen extends StatefulWidget {
  const OfflineSyncScreen({super.key});

  @override
  State<OfflineSyncScreen> createState() => _OfflineSyncScreenState();
}

class _OfflineSyncScreenState extends State<OfflineSyncScreen>
    with AutomaticKeepAliveClientMixin {
  late Future<List<Map<String, dynamic>>> abastecimentos;
  late Future<List<Map<String, dynamic>>> vistorias;
  late Future<List<Map<String, dynamic>>> manutencoes;
  final OfflineSyncService _syncService = OfflineSyncService();
  bool _isSyncing = false;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    // Limpar recursos
    _isSyncing = false;
    super.dispose();
  }

  void _loadData() {
    if (!mounted) return;

    try {
      final db = LocalDatabaseService();
      if (mounted) {
        setState(() {
          abastecimentos = db.getAbastecimentosOffline();
          vistorias = db.getVistoriasSaidaOffline();
          manutencoes = db.getManutencoesOffline();
        });
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
  }

  Future<void> _forceSync() async {
    if (_isSyncing || !mounted) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      final success = await _syncService.forceSync();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sincronização realizada com sucesso!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        // Limpar registros da tela após sincronização
        setState(() {
          abastecimentos = Future.value([]);
          vistorias = Future.value([]);
          manutencoes = Future.value([]);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao sincronizar. Verifique sua conexão.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _deleteOfflineRecord(String type, int id) async {
    if (!mounted) return;

    try {
      final db = LocalDatabaseService();
      if (type == 'abastecimento') {
        await db.deleteAbastecimentoOffline(id);
      } else if (type == 'vistoria') {
        await db.deleteVistoriaSaidaOffline(id);
      } else if (type == 'manutencao') {
        await db.deleteManutencaoOffline(id);
      }

      if (mounted) {
        setState(() {
          _loadData();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar registro: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSyncing ? null : _forceSync,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: _isSyncing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.sync),
        label: Text(_isSyncing ? 'Sincronizando...' : 'Sincronizar'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.backgroundGradientDark
              : AppTheme.backgroundGradientLight,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppTheme.spacing16,
                left: AppTheme.spacing24,
                right: AppTheme.spacing24,
                bottom: AppTheme.spacing20,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkCard.withOpacity(0.8)
                            : AppTheme.lightCard.withOpacity(0.8),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.darkBorder
                              : AppTheme.lightBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: Text(
                      'Sincronização',
                      style: AppTheme.headlineMedium.copyWith(
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo principal
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _loadData();
                  });
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing24,
                    vertical: AppTheme.spacing24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                          'Abastecimentos',
                          abastecimentos,
                          isDark,
                          (item) =>
                              'Veículo: ${item['vehicleId']}\nLitros: ${item['liters']}\nOdômetro: ${item['odometer']}\nData: ${item['dateTime']}',
                          'abastecimento'),
                      const SizedBox(height: AppTheme.spacing24),
                      _buildSection(
                          'Vistorias de Saída',
                          vistorias,
                          isDark,
                          (item) =>
                              'Veículo: ${item['vehicleId']}\nDados: ${item['inspectionData']}\nData: ${item['dateTime']}',
                          'vistoria'),
                      const SizedBox(height: AppTheme.spacing24),
                      _buildSection(
                          'Manutenções',
                          manutencoes,
                          isDark,
                          (item) =>
                              'Veículo: ${item['vehicleId']}\nDescrição: ${item['description']}\nData: ${item['dateTime']}',
                          'manutencao'),
                      const SizedBox(height: 100), // Espaço para o FAB
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      String title,
      Future<List<Map<String, dynamic>>> future,
      bool isDark,
      String Function(Map<String, dynamic>) detailsBuilder,
      String type) {
    final syncErrors = _syncService.getSyncErrors();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.headlineSmall.copyWith(
            color: isDark ? AppTheme.darkText : AppTheme.lightText,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return SizedBox(
                width: double.infinity,
                child: AppTheme.modernCard(
                  isDark: isDark,
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: AppTheme.successColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing12),
                      Text(
                        'Nenhum registro offline',
                        style: AppTheme.titleMedium.copyWith(
                          color:
                              isDark ? AppTheme.darkText : AppTheme.lightText,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        'Todos os dados estão sincronizados',
                        style: AppTheme.bodySmall.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: items.map((item) {
                final id = item['id'] as int;
                final errorKey = '${type}_$id';
                final errorMsg = syncErrors[errorKey];

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
                  child: AppTheme.modernCard(
                    isDark: isDark,
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing8),
                          decoration: BoxDecoration(
                            color: errorMsg != null
                                ? AppTheme.errorColor.withOpacity(0.1)
                                : AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: Icon(
                            errorMsg != null ? Icons.error_outline : Icons.sync,
                            color: errorMsg != null
                                ? AppTheme.errorColor
                                : AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detailsBuilder(item),
                                style: AppTheme.bodyMedium.copyWith(
                                  color: isDark
                                      ? AppTheme.darkText
                                      : AppTheme.lightText,
                                ),
                              ),
                              if (errorMsg != null) ...[
                                const SizedBox(height: AppTheme.spacing8),
                                Container(
                                  padding:
                                      const EdgeInsets.all(AppTheme.spacing8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusSmall),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.warning_rounded,
                                        color: AppTheme.errorColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: AppTheme.spacing8),
                                      Expanded(
                                        child: Text(
                                          _formatSyncError(errorMsg),
                                          style: AppTheme.bodySmall.copyWith(
                                            color: AppTheme.errorColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (errorMsg != null) ...[
                          const SizedBox(width: AppTheme.spacing8),
                          GestureDetector(
                            onTap: () async {
                              await _deleteOfflineRecord(type, id);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.spacing8),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: AppTheme.errorColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  String _formatSyncError(String errorMsg) {
    // Tenta extrair mensagem amigável
    final exp = RegExp(r'Exception: "([^"]+)"');
    final match = exp.firstMatch(errorMsg);
    if (match != null) {
      return match.group(1)!;
    }
    // Remove Exception: se houver
    return errorMsg.replaceAll('Exception:', '').replaceAll('"', '').trim();
  }
}
