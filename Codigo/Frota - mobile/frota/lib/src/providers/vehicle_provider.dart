import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';
import '../models/user.dart';
import '../services/vehicle_service.dart';

class VehicleProvider with ChangeNotifier {
  final VehicleService _vehicleService = VehicleService();

  List<Vehicle> _availableVehicles = [];
  Vehicle? _currentVehicle;
  bool _isLoading = false;
  String? _error;

  List<Vehicle> get availableVehicles => _availableVehicles;
  Vehicle? get currentVehicle => _currentVehicle;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCurrentVehicle => _currentVehicle != null;

  // Carregar veículos disponíveis - método antigo mantido para compatibilidade
  Future<void> loadAvailableVehicles({User? currentUser}) async {
    await fetchAvailableVehicles(currentUser: currentUser);
  }

  // Novo método usado na tela de veículos disponíveis
  Future<void> fetchAvailableVehicles({User? currentUser}) async {
    print('Iniciando busca de veículos disponíveis via provider...');
    _isLoading = true;
    notifyListeners();

    try {
      print(
          'Obtendo veículos disponíveis do serviço. Usuário: ${currentUser?.name ?? 'não informado'}');
      _availableVehicles = await _vehicleService.getAvailableVehicles(
        unidadeAdministrativaId: currentUser?.unidadeAdministrativaId,
      );
      print('Veículos disponíveis recebidos: ${_availableVehicles.length}');

      _error = null;
    } catch (e) {
      print('Erro ao buscar veículos disponíveis no provider: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      print('Notificando ouvintes sobre atualização de veículos disponíveis');
      notifyListeners();
    }
  }

  // Obter veículo por ID
  Future<Vehicle?> getVehicleById(String vehicleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final vehicle = await _vehicleService.getVehicleById(vehicleId);
      _error = null;
      return vehicle;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Selecionar veículo atual
  Future<bool> selectVehicle(String vehicleId, String driverId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final vehicle =
          await _vehicleService.assignVehicleToDriver(vehicleId, driverId);

      if (vehicle != null) {
        _currentVehicle = vehicle;
        _error = null;
        return true;
      } else {
        _error = 'Não foi possível selecionar o veículo';
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

  // Definir veículo atual sem atribuição ao motorista (para navegação direta)
  void setCurrentVehicle(Vehicle vehicle) {
    // Evitar notificação se o veículo for o mesmo
    if (_currentVehicle?.id == vehicle.id) {
      return;
    }

    _currentVehicle = vehicle;
    // Usar Future.microtask para evitar notificação durante a fase de build
    Future.microtask(() => notifyListeners());
  }

  // Liberar veículo atual
  Future<bool> releaseCurrentVehicle() async {
    if (_currentVehicle == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final vehicle = await _vehicleService.releaseVehicle(_currentVehicle!.id);

      if (vehicle != null) {
        _currentVehicle = null;
        _error = null;
        return true;
      } else {
        _error = 'Não foi possível liberar o veículo';
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

  // Atualizar odômetro
  Future<bool> updateOdometer(int newOdometer) async {
    if (_currentVehicle == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final vehicle = await _vehicleService.updateVehicleOdometer(
        _currentVehicle!.id,
        newOdometer,
      );

      if (vehicle != null) {
        _currentVehicle = vehicle;
        _error = null;
        return true;
      } else {
        _error = 'Não foi possível atualizar o odômetro';
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
