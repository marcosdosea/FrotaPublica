import '../repositories/maintenance_repository.dart';
import '../models/maintenance_request.dart';
import '../models/maintenance_priority.dart';

class MaintenanceService {
  final MaintenanceRepository _maintenanceRepository = MaintenanceRepository();

  // Criar solicitação de manutenção
  Future<MaintenanceRequest?> createMaintenanceRequest({
    required String vehicleId,
    required String description,
    MaintenancePriority? priority,
  }) async {
    try {
      return await _maintenanceRepository.registerMaintenanceRequest(
        vehicleId: vehicleId,
        description: description,
        priority: priority,
      );
    } catch (e) {
      print('Erro ao criar solicitação de manutenção: $e');
      return null;
    }
  }

  // Obter solicitações do motorista
  Future<List<MaintenanceRequest>> getMaintenanceRequests() async {
    try {
      return await _maintenanceRepository.getMaintenanceRequests();
    } catch (e) {
      print('Erro ao obter solicitações de manutenção: $e');
      return [];
    }
  }

  // Obter uma solicitação específica
  Future<MaintenanceRequest?> getMaintenanceRequest(String id) async {
    try {
      return await _maintenanceRepository.getMaintenanceRequest(id);
    } catch (e) {
      print('Erro ao obter solicitação de manutenção: $e');
      return null;
    }
  }
}
