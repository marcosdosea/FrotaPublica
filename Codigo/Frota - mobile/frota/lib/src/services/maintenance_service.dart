import '../repositories/maintenance_repository.dart';
import '../models/maintenance_request.dart';

class MaintenanceService {
  final MaintenanceRepository _maintenanceRepository = MaintenanceRepository();

  // Criar solicitação de manutenção
  Future<MaintenanceRequest?> createMaintenanceRequest({
    required String vehicleId,
    required String driverId,
    required String description,
  }) async {
    try {
      return await _maintenanceRepository.createMaintenanceRequest(
        vehicleId: vehicleId,
        driverId: driverId,
        description: description,
      );
    } catch (e) {
      // Em um app real, você pode querer registrar o erro
      return null;
    }
  }

  // Obter solicitações para um veículo
  Future<List<MaintenanceRequest>> getMaintenanceRequestsForVehicle(
      String vehicleId) async {
    try {
      return await _maintenanceRepository
          .getMaintenanceRequestsForVehicle(vehicleId);
    } catch (e) {
      // Em um app real, você pode querer registrar o erro
      return [];
    }
  }

  // Obter solicitações para um motorista
  Future<List<MaintenanceRequest>> getMaintenanceRequestsForDriver(
      String driverId) async {
    try {
      return await _maintenanceRepository
          .getMaintenanceRequestsForDriver(driverId);
    } catch (e) {
      // Em um app real, você pode querer registrar o erro
      return [];
    }
  }
}
