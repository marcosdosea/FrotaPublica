import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'; // Added for WidgetsBinding
import '../models/journey.dart';
import '../services/journey_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../providers/vehicle_provider.dart';

class JourneyProvider with ChangeNotifier {
  final JourneyService _journeyService = JourneyService();

  Journey? _activeJourney;
  List<Journey> _journeyHistory = [];
  bool _isLoading = false;
  String? _error;

  Journey? get activeJourney => _activeJourney;
  List<Journey> get journeyHistory => _journeyHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveJourney => _activeJourney != null;

  // Carregar jornada ativa para um motorista - melhorado para persistência local
  Future<void> loadActiveJourney(String driverId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Primeiro, tentar carregar dados locais
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('active_journey');

      if (saved != null) {
        try {
          _activeJourney = Journey.fromJson(json.decode(saved));
          _error = null;
        } catch (e) {
          print('Erro ao carregar percurso salvo localmente: $e');
          // Se falhar ao carregar local, limpar dados corrompidos
          await prefs.remove('active_journey');
        }
      }

      // Tentar sincronizar com servidor (se online)
      try {
        final onlineJourney =
            await _journeyService.getActiveJourneyForDriver(driverId);
        if (onlineJourney != null) {
          _activeJourney = onlineJourney;
          _error = null;
          // Atualizar dados locais
          await _saveActiveJourneyAndVehicle(_activeJourney!);
        } else if (_activeJourney == null) {
          // Se não há percurso online nem local
          _error = 'Nenhum percurso ativo encontrado';
        }
      } catch (e) {
        print('Erro ao sincronizar com servidor: $e');
        // Se falhar online mas temos dados locais, manter os locais
        if (_activeJourney == null) {
          _error = 'Erro de conexão. Dados locais não disponíveis.';
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar apenas dados locais (para uso offline)
  Future<void> loadLocalJourney() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('active_journey');

      if (saved != null) {
        _activeJourney = Journey.fromJson(json.decode(saved));
        _error = null;
      } else {
        _activeJourney = null;
        _error = 'Nenhum percurso ativo encontrado';
      }
    } catch (e) {
      print('Erro ao carregar percurso local: $e');
      _activeJourney = null;
      _error = 'Erro ao carregar dados locais';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Iniciar uma nova jornada
  Future<bool> startJourney({
    required String vehicleId,
    required String driverId,
    required String origin,
    required String destination,
    required int initialOdometer,
    String? reason,
    double? originLatitude,
    double? originLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
  }) async {
    _isLoading = true;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final journey = await _journeyService.startJourney(
        vehicleId: vehicleId,
        driverId: driverId,
        origin: origin,
        destination: destination,
        initialOdometer: initialOdometer,
        reason: reason,
        originLatitude: originLatitude,
        originLongitude: originLongitude,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
      );

      if (journey != null) {
        _activeJourney = journey;
        _error = null;

        // Salvar localmente
        await _saveActiveJourneyAndVehicle(_activeJourney!);

        return true;
      } else {
        _error = 'Não foi possível iniciar a jornada';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Finalizar jornada ativa
  Future<bool> finishJourney(int finalOdometer) async {
    if (_activeJourney == null) return false;

    _isLoading = true;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final journey = await _journeyService.finishJourney(
        journeyId: _activeJourney!.id,
        finalOdometer: finalOdometer,
      );

      if (journey == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('active_journey');

        _activeJourney = null;
        _error = null;
        
        // Limpar dados do veículo localmente sem notificar o provider
        await prefs.remove('vehicle_${_activeJourney?.vehicleId}');
        
        return true;
      } else {
        _error = 'Não foi possível finalizar a jornada';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Carregar histórico de jornadas
  Future<void> loadJourneyHistory(String driverId) async {
    _isLoading = true;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _journeyHistory =
          await _journeyService.getJourneyHistoryForDriver(driverId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Adicionar abastecimento à jornada ativa
  Future<bool> addFuelRefillToActiveJourney(String fuelRefillId) async {
    if (_activeJourney == null) return false;

    _isLoading = true;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final journey = await _journeyService.addFuelRefillToJourney(
        _activeJourney!.id,
        fuelRefillId,
      );

      if (journey != null) {
        _activeJourney = journey;
        _error = null;

        await _saveActiveJourneyAndVehicle(_activeJourney!);

        return true;
      } else {
        _error = 'Não foi possível adicionar o abastecimento à jornada';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void clearError() {
    _error = null;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> _saveActiveJourneyAndVehicle(Journey journey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_journey', json.encode(journey.toJson()));
    // Salvar veículo localmente
    try {
      final vehicleProvider = VehicleProvider();
      final vehicle = await vehicleProvider.getVehicleById(journey.vehicleId);
      if (vehicle != null) {
        await prefs.setString(
            'vehicle_${vehicle.id}', json.encode(vehicle.toJson()));
      }
    } catch (e) {
      // Ignorar
    }
  }
}
