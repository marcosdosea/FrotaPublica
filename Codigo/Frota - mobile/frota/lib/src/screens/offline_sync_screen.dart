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

class _OfflineSyncScreenState extends State<OfflineSyncScreen> {
  late Future<List<Map<String, dynamic>>> abastecimentos;
  late Future<List<Map<String, dynamic>>> vistorias;
  late Future<List<Map<String, dynamic>>> manutencoes;
  final OfflineSyncService _syncService = OfflineSyncService();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final db = LocalDatabaseService();
    abastecimentos = db.getAbastecimentosOffline();
    vistorias = db.getVistoriasSaidaOffline();
    manutencoes = db.getManutencoesOffline();
  }

  Future<void> _forceSync() async {
    if (_isSyncing) return;
    setState(() {
      _isSyncing = true;
    });
    try {
      final success = await _syncService.forceSync();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sincronização realizada com sucesso!'),
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _deleteOfflineRecord(String type, int id) async {
    final db = LocalDatabaseService();
    if (type == 'abastecimento') {
      await db.deleteAbastecimentoOffline(id);
    } else if (type == 'vistoria') {
      await db.deleteVistoriaSaidaOffline(id);
    } else if (type == 'manutencao') {
      await db.deleteManutencaoOffline(id);
    }
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor:
          isDark ? const Color(0xFF0F0F23) : const Color(0xFFE3F2FD),
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: _isSyncing ? null : _forceSync,
        backgroundColor: const Color(0xFF116AD5),
        child: _isSyncing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.sync, color: Colors.white),
        tooltip: 'Sincronizar registros',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.backgroundGradientDark
              : AppTheme.backgroundGradientLight,
        ),
        child: Column(
          children: [
            // Header igual ao da tela de perfil
            Container(
              padding: const EdgeInsets.only(
                  top: 60, left: 16, right: 16, bottom: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF116AD5),
                    Color(0xFF0066CC),
                    Color(0xFF004BA7),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x29000000),
                    offset: Offset(0, 6),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Registros Offline',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                child: ListView(
                  children: [
                    _buildSection(
                        'Abastecimentos',
                        abastecimentos,
                        isDark,
                        (item) =>
                            'Veículo: ${item['vehicleId']}\nLitros: ${item['liters']}\nOdômetro: ${item['odometer']}\nData: ${item['dateTime']}',
                        'abastecimento'),
                    _buildSection(
                        'Vistorias de Saída',
                        vistorias,
                        isDark,
                        (item) =>
                            'Veículo: ${item['vehicleId']}\nDados: ${item['inspectionData']}\nData: ${item['dateTime']}',
                        'vistoria'),
                    _buildSection(
                        'Manutenções',
                        manutencoes,
                        isDark,
                        (item) =>
                            'Veículo: ${item['vehicleId']}\nDescrição: ${item['description']}\nData: ${item['dateTime']}',
                        'manutencao'),
                  ],
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text('Nenhum $title offline',
                style:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(title,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87)),
            ),
            ...items.map((item) {
              final id = item['id'] as int;
              final errorKey = '${type}_$id';
              final errorMsg = syncErrors[errorKey];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(detailsBuilder(item),
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87)),
                            if (errorMsg != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.red, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _formatSyncError(errorMsg),
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (errorMsg != null) ...[
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Excluir registro',
                          onPressed: () async {
                            await _deleteOfflineRecord(type, id);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
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
