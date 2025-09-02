import 'dart:convert';
import '../models/maintenance_request.dart';
import '../models/maintenance_priority.dart';
import '../utils/api_client.dart';

class MaintenanceRepository {
  // Lista de solicitações de manutenção mockadas
  final List<MaintenanceRequest> _mockRequests = [];

  // Registrar uma nova solicitação de manutenção
  Future<MaintenanceRequest?> registerMaintenanceRequest({
    required String vehicleId,
    required String description,
    MaintenancePriority? priority,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'idVeiculo': int.parse(vehicleId),
        'descricao': description,
      };

      // Adicionar campo de prioridade se fornecido
      if (priority != null) {
        requestData['prioridade'] = priority.code;
      }

      final response =
          await ApiClient.post('SolicitacaoManutencao/registrar', requestData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Buscar a solicitação completa usando o ID retornado
        final requestResponse = await ApiClient.get(
            'SolicitacaoManutencao/${data['idSolicitacao']}');
        if (requestResponse.statusCode == 200) {
          return MaintenanceRequest.fromJson(jsonDecode(requestResponse.body));
        }
      }

      return null;
    } catch (e) {
      print('Erro ao registrar solicitação de manutenção: $e');
      rethrow;
    }
  }

  // Obter solicitações de manutenção do motorista
  Future<List<MaintenanceRequest>> getMaintenanceRequests() async {
    try {
      final response = await ApiClient.get('SolicitacaoManutencao');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((requestJson) => MaintenanceRequest.fromJson(requestJson))
            .toList();
      }

      return [];
    } catch (e) {
      print('Erro ao obter solicitações de manutenção: $e');
      return [];
    }
  }

  // Obter uma solicitação específica
  Future<MaintenanceRequest?> getMaintenanceRequest(String id) async {
    try {
      final response = await ApiClient.get('SolicitacaoManutencao/$id');

      if (response.statusCode == 200) {
        return MaintenanceRequest.fromJson(jsonDecode(response.body));
      }

      return null;
    } catch (e) {
      print('Erro ao obter solicitação de manutenção: $e');
      return null;
    }
  }

  // Obter solicitações de manutenção para um veículo específico
  Future<List<MaintenanceRequest>> getMaintenanceRequestsForVehicle(
      String vehicleId) async {
    return _mockRequests
        .where((request) => request.vehicleId == vehicleId)
        .toList();
  }

  // Obter solicitações de manutenção para um motorista específico
  Future<List<MaintenanceRequest>> getMaintenanceRequestsForDriver(
      String driverId) async {
    return _mockRequests
        .where((request) => request.driverId == driverId)
        .toList();
  }
}
