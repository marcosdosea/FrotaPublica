import '../models/maintenance_request.dart';

class MaintenanceRepository {
  // Lista de solicitações de manutenção mockadas
  final List<MaintenanceRequest> _mockRequests = [];

  // Registrar uma nova solicitação de manutenção
  Future<MaintenanceRequest> createMaintenanceRequest({
    required String vehicleId,
    required String driverId,
    required String description,
  }) async {
    // Simulando uma chamada de API
    await Future.delayed(const Duration(seconds: 1));
    
    final newRequest = MaintenanceRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      vehicleId: vehicleId,
      driverId: driverId,
      description: description,
      timestamp: DateTime.now(),
      status: MaintenanceStatus.pending,
    );
    
    _mockRequests.add(newRequest);
    return newRequest;
  }

  // Obter solicitações de manutenção para um veículo específico
  Future<List<MaintenanceRequest>> getMaintenanceRequestsForVehicle(String vehicleId) async {
    // Simulando uma chamada de API
    await Future.delayed(const Duration(milliseconds: 800));
    
    return _mockRequests
        .where((request) => request.vehicleId == vehicleId)
        .toList();
  }

  // Obter solicitações de manutenção para um motorista específico
  Future<List<MaintenanceRequest>> getMaintenanceRequestsForDriver(String driverId) async {
    // Simulando uma chamada de API
    await Future.delayed(const Duration(milliseconds: 800));
    
    return _mockRequests
        .where((request) => request.driverId == driverId)
        .toList();
  }
}
