import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'; // Added for WidgetsBinding
import '../models/maintenance_request.dart';
import '../models/maintenance_priority.dart';
import '../services/maintenance_service.dart';

class MaintenanceProvider with ChangeNotifier {
  final MaintenanceService _maintenanceService = MaintenanceService();

  List<MaintenanceRequest> _requests = [];
  bool _isLoading = false;
  String? _error;

  List<MaintenanceRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Criar solicitação de manutenção
  Future<bool> createMaintenanceRequest({
    required String vehicleId,
    required String description,
    MaintenancePriority? priority,
  }) async {
    _isLoading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final request = await _maintenanceService.createMaintenanceRequest(
        vehicleId: vehicleId,
        description: description,
        priority: priority,
      );

      if (request != null) {
        _requests.add(request);
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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Carregar solicitações do motorista
  Future<void> loadRequests() async {
    _isLoading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _requests = await _maintenanceService.getMaintenanceRequests();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Limpar erro
  void clearError() {
    _error = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
