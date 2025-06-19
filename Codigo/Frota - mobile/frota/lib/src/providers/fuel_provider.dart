import 'package:flutter/foundation.dart';
import '../models/fuel_refill.dart';
import '../services/fuel_service.dart';

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
    notifyListeners();

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
      notifyListeners();
    }
  }

  // Carregar abastecimentos para um veículo
  Future<void> loadVehicleRefills(String vehicleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _vehicleRefills = await _fuelService.getFuelRefillsForVehicle(vehicleId);
      _totalCost = await _fuelService.getTotalFuelCostForVehicle(vehicleId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Obter total de litros abastecidos para o percurso
  Future<void> loadTotalLitersForJourney(String journeyId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _totalLitersForJourney =
          await _fuelService.getTotalLitersForJourney(journeyId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _totalLitersForJourney = 0.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Zerar total de litros abastecidos para o percurso
  Future<void> clearTotalLitersForJourney(String journeyId) async {
    try {
      await _fuelService.clearTotalLitersForJourney(journeyId);
      _totalLitersForJourney = 0.0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }
}
