import '../repositories/journey_repository.dart';
import '../models/journey.dart';

class JourneyService {
  final JourneyRepository _journeyRepository = JourneyRepository();

  // Obter jornada ativa para um motorista
  Future<Journey?> getActiveJourneyForDriver(String driverId) async {
    try {
      return await _journeyRepository.getActiveJourneyForDriver(driverId);
    } catch (e) {
      print('Erro no serviço ao obter jornada ativa: $e');
      return null;
    }
  }

  // Iniciar uma nova jornada
  Future<Journey?> startJourney({
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
    try {
      return await _journeyRepository.startJourney(
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
    } catch (e) {
      print('Erro no serviço ao iniciar jornada: $e');
      return null;
    }
  }

  // Finalizar uma jornada
  Future<bool> finishJourney({
    required String journeyId,
    required int finalOdometer,
  }) async {
    try {
      return await _journeyRepository.finishJourney(
        journeyId: journeyId,
        finalOdometer: finalOdometer,
      );
    } catch (e) {
      print('Erro no serviço ao finalizar jornada: $e');
      return false;
    }
  }

  // Obter histórico de jornadas
  Future<List<Journey>> getJourneyHistoryForDriver(String driverId) async {
    try {
      return await _journeyRepository.getJourneyHistoryForDriver(driverId);
    } catch (e) {
      print('Erro no serviço ao obter histórico de jornadas: $e');
      return [];
    }
  }

  // Adicionar abastecimento a uma jornada
  Future<Journey?> addFuelRefillToJourney(
      String journeyId, String fuelRefillId) async {
    try {
      return await _journeyRepository.addFuelRefillToJourney(
          journeyId, fuelRefillId);
    } catch (e) {
      print('Erro no serviço ao adicionar abastecimento à jornada: $e');
      return null;
    }
  }
}
