import '../models/fuel_refill.dart';

class FuelRepository {
  // Lista de abastecimentos mockados
  final List<FuelRefill> _mockFuelRefills = [];

  // Registrar um novo abastecimento
  Future<FuelRefill> registerFuelRefill({
    required String journeyId,
    required String vehicleId,
    required String driverId,
    required String gasStation,
    required double liters,
    double? totalCost,
    required int odometerReading,
  }) async {
    // Simulando uma chamada de API
    await Future.delayed(const Duration(seconds: 1));
    
    final newFuelRefill = FuelRefill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      journeyId: journeyId,
      vehicleId: vehicleId,
      driverId: driverId,
      gasStation: gasStation,
      liters: liters,
      totalCost: totalCost,
      odometerReading: odometerReading,
      timestamp: DateTime.now(),
    );
    
    _mockFuelRefills.add(newFuelRefill);
    return newFuelRefill;
  }

  // Obter abastecimentos para um veículo específico
  Future<List<FuelRefill>> getFuelRefillsForVehicle(String vehicleId) async {
    // Simulando uma chamada de API
    await Future.delayed(const Duration(milliseconds: 800));
    
    return _mockFuelRefills
        .where((refill) => refill.vehicleId == vehicleId)
        .toList();
  }

  // Obter abastecimentos para uma jornada específica
  Future<List<FuelRefill>> getFuelRefillsForJourney(String journeyId) async {
    // Simulando uma chamada de API
    await Future.delayed(const Duration(milliseconds: 800));
    
    return _mockFuelRefills
        .where((refill) => refill.journeyId == journeyId)
        .toList();
  }

  // Calcular total de combustível abastecido para um veículo
  Future<double> getTotalFuelCostForVehicle(String vehicleId) async {
    // Simulando uma chamada de API
    await Future.delayed(const Duration(milliseconds: 500));
    
    final refills = _mockFuelRefills.where((refill) => refill.vehicleId == vehicleId);
    
    if (refills.isEmpty) {
      return 0.0;
    }
    
    return refills
        .map((refill) => refill.totalCost ?? 0.0)
        .reduce((value, element) => value + element);
  }
}
