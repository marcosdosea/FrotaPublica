import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'; // Added for WidgetsBinding
import '../models/fuel_refill.dart';
import '../services/fuel_service.dart';
import '../services/local_database_service.dart';

class FuelProvider with ChangeNotifier {
  final FuelService _fuelService = FuelService();

  List<FuelRefill> _vehicleRefills = [];
  double _totalCost = 0.0;
  bool _isLoading = false;
  String? _error;
  double _totalLitersForJourney = 0.0;

  List<FuelRefill> get vehicleRefills => _vehicleRefills;
  double get totalCost => _totalCost;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalLitersForJourney => _totalLitersForJourney;

  // Registrar abastecimento
  Future<FuelRefill?> registerFuelRefill({
    required String journeyId,
    required String vehicleId,
    required String driverId,
    required String gasStation,
    required double liters,
    double? totalCost,
    required int odometerReading,
  }) async {
    _isLoading = true;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final refill = await _fuelService.registerFuelRefill(
        journeyId: journeyId,
        vehicleId: vehicleId,
        driverId: driverId,
        gasStation: gasStation,
        liters: liters,
        totalCost: totalCost,
        odometerReading: odometerReading,
      );

      if (refill != null) {
        _vehicleRefills.add(refill);
        _error = null;
      } else {
        _error = 'Não foi possível registrar o abastecimento';
      }

      return refill;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Carregar abastecimentos para um veículo
  Future<void> loadVehicleRefills(String vehicleId) async {
    _isLoading = true;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _vehicleRefills = await _fuelService.getFuelRefillsForVehicle(vehicleId);
      _totalCost = await _fuelService.getTotalFuelCostForVehicle(vehicleId);
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

  // Limpar erro
  void clearError() {
    _error = null;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Obter total de litros abastecidos para o percurso (considerando offline)
  Future<void> loadTotalLitersForJourney(String journeyId,
      {String? vehicleId}) async {
    _isLoading = true;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    
    try {
      // Litros online/persistido
      double totalOnline =
          await _fuelService.getTotalLitersForJourney(journeyId);
      // Litros offline
      double totalOffline = 0.0;
      if (vehicleId != null) {
        final offlineList =
            await LocalDatabaseService().getAbastecimentosOffline();
        totalOffline = offlineList
            .where((item) =>
                item['journeyId'] == journeyId &&
                item['vehicleId'] == vehicleId)
            .fold(0.0, (sum, item) => sum + (item['liters'] as num? ?? 0.0));
      }
      _totalLitersForJourney = totalOnline + totalOffline;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _totalLitersForJourney = 0.0;
    } finally {
      _isLoading = false;
      
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Zerar total de litros abastecidos para o percurso
  Future<void> clearTotalLitersForJourney(String journeyId) async {
    try {
      await _fuelService.clearTotalLitersForJourney(journeyId);
      _totalLitersForJourney = 0.0;
      
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
    }
  }
}
