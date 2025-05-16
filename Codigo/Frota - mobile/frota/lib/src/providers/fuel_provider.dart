import 'package:flutter/foundation.dart';
import '../models/fuel_refill.dart';
import '../services/fuel_service.dart';

class FuelProvider with ChangeNotifier {
  final FuelService _fuelService = FuelService();

  List<FuelRefill> _vehicleRefills = [];
  double _totalCost = 0.0;
  bool _isLoading = false;
  String? _error;

  List<FuelRefill> get vehicleRefills => _vehicleRefills;
  double get totalCost => _totalCost;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
}
