import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'local_database_service.dart';
import '../repositories/fuel_repository.dart';
import '../repositories/inspection_repository.dart';
import '../repositories/maintenance_repository.dart';

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  final LocalDatabaseService _db = LocalDatabaseService();
  final FuelRepository _fuelRepository = FuelRepository();
  final InspectionRepository _inspectionRepository = InspectionRepository();
  final MaintenanceRepository _maintenanceRepository = MaintenanceRepository();

  StreamSubscription<ConnectivityResult>? _connectivitySub;
  bool _isSyncing = false;
  bool _isOnline = true;

  // Novo: Map para armazenar erros de sincronização por tipo e id
  final Map<String, String> syncErrors = {};

  void start() {
    _checkInitialConnectivity();
    _connectivitySub ??= Connectivity().onConnectivityChanged.listen((result) {
      final wasOffline = !_isOnline;
      _isOnline = result != ConnectivityResult.none;

      if (wasOffline && _isOnline) {
        // Acabou de voltar online, sincronizar automaticamente
        print('Conexão restaurada, iniciando sincronização automática...');
        syncAll();
      }
    });
    // Tenta sincronizar ao iniciar se estiver online
    if (_isOnline) {
      syncAll();
    }
  }

  Future<void> _checkInitialConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
  }

  void dispose() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  Future<void> syncAll() async {
    if (_isSyncing) {
      print('Sincronização já em andamento, ignorando chamada');
      return;
    }

    if (!_isOnline) {
      print('Dispositivo offline, não é possível sincronizar');
      return;
    }

    _isSyncing = true;
    print('Iniciando sincronização de todos os dados offline...');
    syncErrors.clear(); // Limpa erros antigos

    try {
      final results = await Future.wait([
        _syncAbastecimentos(),
        _syncVistoriasSaida(),
        _syncManutencoes(),
      ], eagerError: false);

      int successCount = 0;
      for (final result in results) {
        if (result) successCount++;
      }

      print(
          'Sincronização concluída: $successCount de ${results.length} operações bem-sucedidas');
    } catch (e) {
      print('Erro durante sincronização: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Forçar sincronização (para uso manual)
  Future<bool> forceSync() async {
    if (!_isOnline) {
      print('Dispositivo offline, não é possível sincronizar');
      return false;
    }

    print('Forçando sincronização manual...');
    await syncAll();
    return true;
  }

  Future<bool> _syncAbastecimentos() async {
    try {
      final list = await _db.getAbastecimentosOffline();
      print('Sincronizando  [33m${list.length} [0m abastecimentos offline...');

      int successCount = 0;
      for (final item in list) {
        try {
          final success = await _fuelRepository.registerFuelRefill(
            journeyId: item['journeyId']?.toString() ?? '0',
            vehicleId: item['vehicleId'].toString(),
            driverId: item['driverId']?.toString() ?? '1',
            gasStation: item['supplier']?.toString() ?? '1',
            liters: double.parse(item['liters'].toString()),
            totalCost: double.tryParse(item['value']?.toString() ?? '0'),
            odometerReading: int.parse(item['odometer'].toString()),
          );

          if (success != null) {
            await _db.deleteAbastecimentoOffline(item['id'] as int);
            successCount++;
          }
        } catch (e) {
          print('Erro ao sincronizar abastecimento ${item['id']}: $e');
          syncErrors['abastecimento_${item['id']}'] = e.toString();
        }
      }

      print('Abastecimentos sincronizados: $successCount de ${list.length}');
      return successCount == list.length;
    } catch (e) {
      print('Erro ao sincronizar abastecimentos: $e');
      return false;
    }
  }

  Future<bool> _syncVistoriasSaida() async {
    try {
      final list = await _db.getVistoriasSaidaOffline();
      print('Sincronizando ${list.length} vistorias offline...');

      int successCount = 0;
      for (final item in list) {
        try {
          final success = await _inspectionRepository.registerInspection(
            vehicleId: item['vehicleId'].toString(),
            type: item['inspectionType']?.toString() ?? 'S',
            problems: item['observations']?.toString(),
          );

          if (success != null) {
            await _db.deleteVistoriaSaidaOffline(item['id'] as int);
            successCount++;
          }
        } catch (e) {
          print('Erro ao sincronizar vistoria ${item['id']}: $e');
          syncErrors['vistoria_${item['id']}'] = e.toString();
        }
      }

      print('Vistorias sincronizadas: $successCount de ${list.length}');
      return successCount == list.length;
    } catch (e) {
      print('Erro ao sincronizar vistorias: $e');
      return false;
    }
  }

  Future<bool> _syncManutencoes() async {
    try {
      final list = await _db.getManutencoesOffline();
      print('Sincronizando ${list.length} manutenções offline...');

      int successCount = 0;
      for (final item in list) {
        try {
          final success =
              await _maintenanceRepository.registerMaintenanceRequest(
            vehicleId: item['vehicleId'].toString(),
            description: item['description'].toString(),
          );

          if (success != null) {
            await _db.deleteManutencaoOffline(item['id'] as int);
            successCount++;
          }
        } catch (e) {
          print('Erro ao sincronizar manutenção ${item['id']}: $e');
          syncErrors['manutencao_${item['id']}'] = e.toString();
        }
      }

      print('Manutenções sincronizadas: $successCount de ${list.length}');
      return successCount == list.length;
    } catch (e) {
      print('Erro ao sincronizar manutenções: $e');
      return false;
    }
  }

  // Obter estatísticas de dados offline
  Future<Map<String, int>> getOfflineStats() async {
    try {
      final abastecimentos = await _db.getAbastecimentosOffline();
      final vistorias = await _db.getVistoriasSaidaOffline();
      final manutencoes = await _db.getManutencoesOffline();

      return {
        'abastecimentos': abastecimentos.length,
        'vistorias': vistorias.length,
        'manutencoes': manutencoes.length,
      };
    } catch (e) {
      print('Erro ao obter estatísticas offline: $e');
      return {
        'abastecimentos': 0,
        'vistorias': 0,
        'manutencoes': 0,
      };
    }
  }

  // Verificar se há dados para sincronizar
  Future<bool> hasOfflineData() async {
    final stats = await getOfflineStats();
    return stats.values.any((count) => count > 0);
  }

  // Obter status da sincronização
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;

  // Expor os erros para a tela
  Map<String, String> getSyncErrors() => syncErrors;
}
