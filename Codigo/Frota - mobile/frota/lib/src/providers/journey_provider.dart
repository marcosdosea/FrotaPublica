import 'package:flutter/foundation.dart';
import '../models/journey.dart';
import '../services/journey_service.dart';

class JourneyProvider with ChangeNotifier {
  final JourneyService _journeyService = JourneyService();

  Journey? _activeJourney;
  List<Journey> _journeyHistory = [];
  bool _isLoading = false;
  String? _error;

  Journey? get activeJourney => _activeJourney;
  List<Journey> get journeyHistory => _journeyHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveJourney => _activeJourney != null;

  // Carregar jornada ativa para um motorista
  Future<void> loadActiveJourney(String driverId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _activeJourney =
          await _journeyService.getActiveJourneyForDriver(driverId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Iniciar uma nova jornada
  Future<bool> startJourney({
    required String vehicleId,
    required String driverId,
    required String origin,
    required String destination,
    required int initialOdometer,
    String? reason,
    double? originLatitude,
    double? originLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final journey = await _journeyService.startJourney(
        vehicleId: vehicleId,
        driverId: driverId,
        origin: origin,
        destination: destination,
        initialOdometer: initialOdometer,
        reason: reason,
        originLatitude: originLatitude,
        originLongitude: originLongitude,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
      );

      if (journey != null) {
        _activeJourney = journey;
        _error = null;
        return true;
      } else {
        _error = 'Não foi possível iniciar a jornada';
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

  // Finalizar jornada ativa
  Future<bool> finishJourney(int finalOdometer) async {
    if (_activeJourney == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final journey = await _journeyService.finishJourney(
        journeyId: _activeJourney!.id,
        finalOdometer: finalOdometer,
      );

      if (journey == true) {
        return true;
      } else {
        _error = 'Não foi possível finalizar a jornada';
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

  // Carregar histórico de jornadas
  Future<void> loadJourneyHistory(String driverId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _journeyHistory =
          await _journeyService.getJourneyHistoryForDriver(driverId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adicionar abastecimento à jornada ativa
  Future<bool> addFuelRefillToActiveJourney(String fuelRefillId) async {
    if (_activeJourney == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final journey = await _journeyService.addFuelRefillToJourney(
        _activeJourney!.id,
        fuelRefillId,
      );

      if (journey != null) {
        _activeJourney = journey;
        _error = null;
        return true;
      } else {
        _error = 'Não foi possível adicionar o abastecimento à jornada';
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

  // Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
