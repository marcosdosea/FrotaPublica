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
      // Chamar o repository e retornar o resultado
      final result = await _fuelRepository.registerFuelRefill(
        journeyId: journeyId,
        vehicleId: vehicleId,
        driverId: driverId,
        gasStation: gasStation,
        liters: liters,
        totalCost: totalCost,
        odometerReading: odometerReading,
      );

      // Log para depuração
      print('FuelService: Resultado do registro de abastecimento: $result');

      return result;
    } catch (e) {
      // Registrar o erro e propagar a exceção para ser tratada na UI
      print('FuelService: Erro ao registrar abastecimento: $e');
      rethrow;
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

  Future<void> addLitersToJourneyTotal(String journeyId, double liters) async {
    try{
      return await _fuelRepository.addLitersToJourneyTotal(journeyId, liters);
    } catch (e){
      return;
    }
  }

  // Obtém o total de litros abastecidos para o percurso
  Future<double> getTotalLitersForJourney(String journeyId) async {
    try {
      return await _fuelRepository.getTotalLitersForJourney(journeyId);
    } catch (e) {
      print('FuelService: Erro ao obter total de litros do percurso: $e');
      return 0.0;
    }
  }

  // Zera o total de litros abastecidos para o percurso
  Future<void> clearTotalLitersForJourney(String journeyId) async {
    try {
      await _fuelRepository.clearTotalLitersForJourney(journeyId);
    } catch (e) {
      print('FuelService: Erro ao zerar total de litros do percurso: $e');
    }
  }
}
