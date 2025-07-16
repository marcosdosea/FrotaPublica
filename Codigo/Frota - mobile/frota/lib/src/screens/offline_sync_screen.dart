import 'package:flutter/material.dart';
import '../services/local_database_service.dart';

class OfflineSyncScreen extends StatefulWidget {
  const OfflineSyncScreen({super.key});

  @override
  State<OfflineSyncScreen> createState() => _OfflineSyncScreenState();
}

class _OfflineSyncScreenState extends State<OfflineSyncScreen> {
  late Future<List<Map<String, dynamic>>> abastecimentos;
  late Future<List<Map<String, dynamic>>> vistorias;
  late Future<List<Map<String, dynamic>>> manutencoes;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros Offline'),
        backgroundColor: const Color(0xFF116AD5),
      ),
      body: RefreshIndicator(
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
                    'Veículo: ${item['vehicleId']}\nLitros: ${item['liters']}\nOdômetro: ${item['odometer']}\nData: ${item['dateTime']}'),
            _buildSection(
                'Vistorias de Saída',
                vistorias,
                isDark,
                (item) =>
                    'Veículo: ${item['vehicleId']}\nDados: ${item['inspectionData']}\nData: ${item['dateTime']}'),
            _buildSection(
                'Manutenções',
                manutencoes,
                isDark,
                (item) =>
                    'Veículo: ${item['vehicleId']}\nDescrição: ${item['description']}\nData: ${item['dateTime']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Future<List<Map<String, dynamic>>> future,
      bool isDark, String Function(Map<String, dynamic>) detailsBuilder) {
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
            ...items.map((item) => Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(detailsBuilder(item),
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87)),
                  ),
                )),
          ],
        );
      },
    );
  }
}
