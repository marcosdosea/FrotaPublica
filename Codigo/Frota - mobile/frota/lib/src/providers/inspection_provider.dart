import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'; // Added for WidgetsBinding
import '../models/inspection.dart';
import '../models/inspection_status.dart';
import '../services/inspection_service.dart';

class InspectionProvider with ChangeNotifier {
  final InspectionService _inspectionService = InspectionService();

  InspectionStatus _inspectionStatus = InspectionStatus();
  List<Inspection> _vehicleInspections = [];
  bool _isLoading = false;
  String? _error;

  InspectionStatus get inspectionStatus => _inspectionStatus;
  List<Inspection> get vehicleInspections => _vehicleInspections;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Carregar status de inspeção para uma jornada
  Future<void> loadInspectionStatus(String journeyId) async {
    _isLoading = true;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _inspectionStatus =
          await _inspectionService.getInspectionStatusForJourney(journeyId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Registrar inspeção
  Future<bool> registerInspection({
    required String vehicleId,
    required String type, // "S" (saída) ou "R" (retorno)
    String? problems,
  }) async {
    _isLoading = true;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final inspection = await _inspectionService.registerInspection(
        vehicleId: vehicleId,
        type: type,
        problems: problems,
      );

      if (inspection != null) {
        // Atualizar o status de inspeção
        if (type == 'S') {
          _inspectionStatus =
              _inspectionStatus.copyWith(departureInspectionCompleted: true);
        } else if (type == 'R') {
          _inspectionStatus =
              _inspectionStatus.copyWith(arrivalInspectionCompleted: true);
        }

        _error = null;
        return true;
      } else {
        _error = 'Não foi possível registrar a inspeção';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Carregar inspeções para um veículo
  Future<void> loadVehicleInspections(String vehicleId) async {
    _isLoading = true;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _vehicleInspections =
          await _inspectionService.getInspectionsForVehicle(vehicleId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Limpar erro
  void clearError() {
    _error = null;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
