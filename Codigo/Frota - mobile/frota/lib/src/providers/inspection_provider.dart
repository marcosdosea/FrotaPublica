import 'package:flutter/foundation.dart';
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
    notifyListeners();
    
    try {
      _inspectionStatus = await _inspectionService.getInspectionStatusForJourney(journeyId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Registrar inspeção
  Future<bool> registerInspection({
    required String journeyId,
    required String vehicleId,
    required String driverId,
    required InspectionType type,
    String? problems,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final inspection = await _inspectionService.registerInspection(
        journeyId: journeyId,
        vehicleId: vehicleId,
        driverId: driverId,
        type: type,
        problems: problems,
      );
      
      if (inspection != null) {
        // Atualizar o status de inspeção
        if (type == InspectionType.departure) {
          _inspectionStatus = _inspectionStatus.copyWith(departureInspectionCompleted: true);
        } else {
          _inspectionStatus = _inspectionStatus.copyWith(arrivalInspectionCompleted: true);
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
      notifyListeners();
    }
  }
  
  // Carregar inspeções para um veículo
  Future<void> loadVehicleInspections(String vehicleId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _vehicleInspections = await _inspectionService.getInspectionsForVehicle(vehicleId);
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
