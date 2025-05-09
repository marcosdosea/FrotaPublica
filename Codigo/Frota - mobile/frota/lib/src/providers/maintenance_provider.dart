import 'package:flutter/foundation.dart';
import '../models/maintenance_request.dart';
import '../services/maintenance_service.dart';

class MaintenanceProvider with ChangeNotifier {
  final MaintenanceService _maintenanceService = MaintenanceService();
  
  List<MaintenanceRequest> _driverRequests = [];
  bool _isLoading = false;
  String? _error;
  
  List<MaintenanceRequest> get driverRequests => _driverRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Criar solicitação de manutenção
  Future<bool> createMaintenanceRequest({
    required String vehicleId,
    required String driverId,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final request = await _maintenanceService.createMaintenanceRequest(
        vehicleId: vehicleId,
        driverId: driverId,
        description: description,
      );
      
      if (request != null) {
        _driverRequests.add(request);
        _error = null;
        return true;
      } else {
        _error = 'Não foi possível criar a solicitação de manutenção';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Carregar solicitações para um motorista
  Future<void> loadDriverRequests(String driverId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _driverRequests = await _maintenanceService.getMaintenanceRequestsForDriver(driverId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
