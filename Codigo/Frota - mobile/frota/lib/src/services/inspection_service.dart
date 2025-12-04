import '../repositories/inspection_repository.dart';
import '../models/inspection.dart';
import '../models/inspection_status.dart';

class InspectionService {
  final InspectionRepository _inspectionRepository = InspectionRepository();

  // Registrar vistoria
  Future<Inspection?> registerInspection({
    required String vehicleId,
    required String type, // "S" (saída) ou "R" (retorno)
    String? problems,
  }) async {
    try {
      // Chamar o repository e retornar o resultado
      final result = await _inspectionRepository.registerInspection(
        vehicleId: vehicleId,
        type: type,
        problems: problems,
      );

      // Log para depuração
      print('InspectionService: Resultado do registro de vistoria: $result');

      return result;
    } catch (e) {
      // Registrar o erro e propagar a exceção para ser tratada na UI
      print('InspectionService: Erro ao registrar vistoria: $e');
      rethrow;
    }
  }

  // Verifica se o tipo de vistoria já foi registrado para o veículo no percurso atual
  Future<bool> hasInspectionBeenCompleted(String vehicleId, String type) async {
    try {
      return await _inspectionRepository.hasInspectionBeenCompleted(
          vehicleId, type);
    } catch (e) {
      print('InspectionService: Erro ao verificar vistoria: $e');
      return false;
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

  // Limpar o status das vistorias para um veículo
  Future<void> clearInspectionStatus(String vehicleId) async {
    try {
      await _inspectionRepository.clearInspectionStatus(vehicleId);
    } catch (e) {
      print('InspectionService: Erro ao limpar status das vistorias: $e');
    }
  }
}
