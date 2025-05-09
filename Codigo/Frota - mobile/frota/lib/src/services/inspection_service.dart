import '../repositories/inspection_repository.dart';
import '../models/inspection.dart';
import '../models/inspection_status.dart';

class InspectionService {
  final InspectionRepository _inspectionRepository = InspectionRepository();

  // Registrar inspeção
  Future<Inspection?> registerInspection({
    required String journeyId,
    required String vehicleId,
    required String driverId,
    required InspectionType type,
    String? problems,
  }) async {
    try {
      return await _inspectionRepository.registerInspection(
        journeyId: journeyId,
        vehicleId: vehicleId,
        driverId: driverId,
        type: type,
        problems: problems,
      );
    } catch (e) {
      print('Erro no serviço ao registrar inspeção: $e');
      return null;
    }
  }

  // Obter status de inspeção
  Future<InspectionStatus> getInspectionStatusForJourney(
      String journeyId) async {
    try {
      return await _inspectionRepository
          .getInspectionStatusForJourney(journeyId);
    } catch (e) {
      print('Erro no serviço ao obter status de inspeção: $e');
      return InspectionStatus();
    }
  }

  // Obter inspeções para um veículo
  Future<List<Inspection>> getInspectionsForVehicle(String vehicleId) async {
    try {
      return await _inspectionRepository.getInspectionsForVehicle(vehicleId);
    } catch (e) {
      print('Erro no serviço ao obter inspeções por veículo: $e');
      return [];
    }
  }
}
