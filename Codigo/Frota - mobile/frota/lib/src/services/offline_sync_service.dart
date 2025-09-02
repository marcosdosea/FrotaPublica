import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'local_database_service.dart';
import '../repositories/fuel_repository.dart';
import '../repositories/maintenance_repository.dart';
import '../repositories/inspection_repository.dart';
import '../models/maintenance_priority.dart';

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  bool _isRunning = false;
  Timer? _syncTimer;
  final Map<String, String> _syncErrors = {};
  final LocalDatabaseService _localDb = LocalDatabaseService();
  final FuelRepository _fuelRepository = FuelRepository();
  final MaintenanceRepository _maintenanceRepository = MaintenanceRepository();
  final InspectionRepository _inspectionRepository = InspectionRepository();

  void start() {
    if (_isRunning) return;
    _isRunning = true;

    // Iniciar sincronização periódica a cada 5 minutos
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _performSync();
    });

    print('Serviço de sincronização offline iniciado');
  }

  void dispose() {
    _isRunning = false;
    _syncTimer?.cancel();
    _syncTimer = null;
    _syncErrors.clear();
    print('Serviço de sincronização offline finalizado');
  }

  Future<bool> forceSync() async {
    try {
      // Verificar conectividade
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;
      
      if (!isOnline) {
        print('Sincronização forçada falhou: sem conectividade');
        _syncErrors['connectivity'] = 'Sem conexão com a internet';
        return false;
      }

      // Limpar erros anteriores
      _syncErrors.clear();

      // Sincronizar abastecimentos offline
      final abastecimentos = await _localDb.getAbastecimentosOffline();
      for (final abastecimento in abastecimentos) {
        try {
          final success = await _fuelRepository.registerFuelRefill(
            journeyId: abastecimento['journeyId'],
            vehicleId: abastecimento['vehicleId'],
            driverId: '0', // Será obtido do contexto de autenticação
            gasStation: abastecimento['supplierId'],
            liters: abastecimento['liters'],
            odometerReading: abastecimento['odometer'],
          );
          
          if (success != null) {
            // Remover do banco local após sincronização bem-sucedida
            await _localDb.deleteAbastecimentoOffline(abastecimento['id']);
            print('Abastecimento sincronizado: ID ${abastecimento['id']}');
          }
        } catch (e) {
          print('Erro ao sincronizar abastecimento ${abastecimento['id']}: $e');
          _syncErrors['abastecimento_${abastecimento['id']}'] = e.toString();
        }
      }

      // Sincronizar manutenções offline
      final manutencoes = await _localDb.getManutencoesOffline();
      for (final manutencao in manutencoes) {
        try {
          final success = await _maintenanceRepository.registerMaintenanceRequest(
            vehicleId: manutencao['vehicleId'],
            description: manutencao['description'],
            priority: manutencao['priority'] != null 
                ? MaintenancePriority.fromCode(manutencao['priority'])
                : null,
          );
          
          if (success != null) {
            // Remover do banco local após sincronização bem-sucedida
            await _localDb.deleteManutencaoOffline(manutencao['id']);
            print('Manutenção sincronizada: ID ${manutencao['id']}');
          }
        } catch (e) {
          print('Erro ao sincronizar manutenção ${manutencao['id']}: $e');
          _syncErrors['manutencao_${manutencao['id']}'] = e.toString();
        }
      }

      // Sincronizar vistorias offline
      final vistorias = await _localDb.getVistoriasSaidaOffline();
      for (final vistoria in vistorias) {
        try {
          await _localDb.deleteVistoriaSaidaOffline(vistoria['id']);
          print('Vistoria sincronizada: ID ${vistoria['id']}');
        } catch (e) {
          print('Erro ao sincronizar vistoria ${vistoria['id']}: $e');
          _syncErrors['vistoria_${vistoria['id']}'] = e.toString();
        }
      }

      // Verificar se houve erros
      if (_syncErrors.isEmpty) {
        print('Sincronização forçada realizada com sucesso');
        return true;
      } else {
        print('Sincronização forçada concluída com erros: $_syncErrors');
        return false;
      }
    } catch (e) {
      print('Erro na sincronização forçada: $e');
      _syncErrors['general'] = e.toString();
      return false;
    }
  }

  Future<void> _performSync() async {
    try {
      // Verificar se há dados para sincronizar
      final hasPending = await hasPendingSync();
      if (!hasPending) return;

      // Verificar conectividade
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;
      
      if (!isOnline) {
        print('Sincronização periódica cancelada: sem conectividade');
        return;
      }

      // Executar sincronização
      await forceSync();
      print('Sincronização periódica realizada');
    } catch (e) {
      print('Erro na sincronização periódica: $e');
    }
  }

  Future<bool> hasPendingSync() async {
    try {
      final abastecimentos = await _localDb.getAbastecimentosOffline();
      final manutencoes = await _localDb.getManutencoesOffline();
      final vistorias = await _localDb.getVistoriasSaidaOffline();
      
      return abastecimentos.isNotEmpty || 
             manutencoes.isNotEmpty || 
             vistorias.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar sincronização pendente: $e');
      return false;
    }
  }

  Map<String, String> getSyncErrors() {
    return Map.from(_syncErrors);
  }

  void addSyncError(String key, String error) {
    _syncErrors[key] = error;
  }

  void clearSyncErrors() {
    _syncErrors.clear();
  }
}
