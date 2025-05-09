import 'dart:convert';
import '../models/inspection.dart';
import '../models/inspection_status.dart';
import '../utils/api_client.dart';

class InspectionRepository {
  // Registrar uma nova inspeção
  Future<Inspection?> registerInspection({
    required String journeyId,
    required String vehicleId,
    required String driverId,
    required InspectionType type,
    String? problems,
  }) async {
    try {
      final response = await ApiClient.post('Vistorias', {
        'percursoId': journeyId,
        'veiculoId': vehicleId,
        'motoristaId': driverId,
        'tipo': type == InspectionType.departure ? 'Saida' : 'Entrega',
        'problemas': problems,
        'dataHora': DateTime.now().toIso8601String(),
        'concluida': true,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Inspection.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Erro ao registrar inspeção: $e');
      return null;
    }
  }

  // Obter status de inspeção para uma jornada
  Future<InspectionStatus> getInspectionStatusForJourney(
      String journeyId) async {
    try {
      final response =
          await ApiClient.get('Vistorias/status/percurso/$journeyId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return InspectionStatus(
          departureInspectionCompleted: data['saidaConcluida'] ?? false,
          arrivalInspectionCompleted: data['chegadaConcluida'] ?? false,
        );
      }

      return InspectionStatus(
        departureInspectionCompleted: false,
        arrivalInspectionCompleted: false,
      );
    } catch (e) {
      print('Erro ao obter status de inspeção: $e');
      return InspectionStatus(
        departureInspectionCompleted: false,
        arrivalInspectionCompleted: false,
      );
    }
  }

  // Obter inspeções para um veículo específico
  Future<List<Inspection>> getInspectionsForVehicle(String vehicleId) async {
    try {
      final response = await ApiClient.get('Vistorias/veiculo/$vehicleId');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((inspectionJson) => Inspection.fromJson(inspectionJson))
            .toList();
      }

      return [];
    } catch (e) {
      print('Erro ao obter inspeções por veículo: $e');
      return [];
    }
  }
}
