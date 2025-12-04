import 'dart:convert';
import '../models/inspection.dart';
import '../models/inspection_status.dart';
import '../utils/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InspectionRepository {
  static const String _completedDepartureKey = 'inspection_departure_';
  static const String _completedArrivalKey = 'inspection_arrival_';

  // Registrar uma nova inspeção
  Future<Inspection?> registerInspection({
    required String vehicleId,
    required String type, // "S" (saída) ou "R" (retorno)
    String? problems,
  }) async {
    try {
      final response = await ApiClient.post('Vistoria/registrar', {
        'idVeiculo': int.parse(vehicleId),
        'tipo': type, // "S" ou "R"
        'problemas': problems ?? '',
      });

      print('Resposta da API: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Criar objeto de inspeção
        final inspection = Inspection(
          id: data['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          vehicleId: vehicleId,
          type: type,
          problems: problems,
          timestamp: DateTime.now(),
        );

        await _markInspectionAsCompleted(vehicleId, type);

        return inspection;
      }

      return null;
    } catch (e) {
      print('Erro ao registrar inspeção: $e');
      rethrow;
    }
  }

  // Marcar uma vistoria como completada
  Future<void> _markInspectionAsCompleted(String vehicleId, String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (type == 'S') {
        await prefs.setBool('$_completedDepartureKey$vehicleId', true);
      } else if (type == 'R') {
        await prefs.setBool('$_completedArrivalKey$vehicleId', true);
      }
    } catch (e) {
      print('Erro ao marcar vistoria como completada: $e');
    }
  }

  // Verificar se um tipo de vistoria já foi completado
  Future<bool> hasInspectionBeenCompleted(String vehicleId, String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (type == 'S') {
        return prefs.getBool('$_completedDepartureKey$vehicleId') ?? false;
      } else if (type == 'R') {
        return prefs.getBool('$_completedArrivalKey$vehicleId') ?? false;
      }

      return false;
    } catch (e) {
      print('Erro ao verificar vistoria completada: $e');
      return false;
    }
  }

  // Limpar o status das vistorias para um veículo
  Future<void> clearInspectionStatus(String vehicleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_completedDepartureKey$vehicleId');
      await prefs.remove('$_completedArrivalKey$vehicleId');
      print('Status das vistorias limpo para o veículo: $vehicleId');
    } catch (e) {
      print('Erro ao limpar status das vistorias: $e');
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
