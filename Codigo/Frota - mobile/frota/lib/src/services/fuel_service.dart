import '../repositories/fuel_repository.dart';
import '../models/fuel_refill.dart';

class FuelService {
  final FuelRepository _fuelRepository = FuelRepository();
  
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
    try {
      return await _fuelRepository.registerFuelRefill(
        journeyId: journeyId,
        vehicleId: vehicleId,
        driverId: driverId,
        gasStation: gasStation,
        liters: liters,
        totalCost: totalCost,
        odometerReading: odometerReading,
      );
    } catch (e) {
      // Em um app real, você pode querer registrar o erro
      return null;
    }
  }
  
  // Obter abastecimentos para um veículo
  Future<List<FuelRefill>> getFuelRefillsForVehicle(String vehicleId) async {
    try {
      return await _fuelRepository.getFuelRefillsForVehicle(vehicleId);
    } catch (e) {
      // Em um app real, você pode querer registrar o erro
      return [];
    }
  }
  
  // Obter abastecimentos para uma jornada
  Future<List<FuelRefill>> getFuelRefillsForJourney(String journeyId) async {
    try {
      return await _fuelRepository.getFuelRefillsForJourney(journeyId);
    } catch (e) {
      // Em um app real, você pode querer registrar o erro
      return [];
    }
  }
  
  // Calcular custo total de combustível
  Future<double> getTotalFuelCostForVehicle(String vehicleId) async {
    try {
      return await _fuelRepository.getTotalFuelCostForVehicle(vehicleId);
    } catch (e) {
      // Em um app real, você pode querer registrar o erro
      return 0.0;
    }
  }
}
