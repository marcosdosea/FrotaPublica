import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';
import '../models/user.dart';
import '../services/vehicle_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart'; // Added for WidgetsBinding

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Obter veículo por ID
  Future<Vehicle?> getVehicleById(String id) async {
    try {
      final vehicle = await _vehicleService.getVehicleById(id);
      if (vehicle != null) {
        // Salvar localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('vehicle_$id', json.encode(vehicle.toJson()));
        return vehicle;
      }
    } catch (e) {
      // Se falhar (offline), tentar carregar localmente
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('vehicle_$id');
      if (saved != null) {
        return Vehicle.fromJson(json.decode(saved));
      }
    }
    return null;
  }

  // Selecionar veículo atual
  Future<bool> selectVehicle(String vehicleId, String driverId) async {
    _isLoading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Definir veículo atual sem atribuição ao motorista (para navegação direta)
  void setCurrentVehicle(Vehicle vehicle) {
    _currentVehicle = vehicle;
    _error = null;
    notifyListeners();
  }

  // Limpar veículo atual sem notificar (para evitar setState durante build)
  void clearCurrentVehicleSilently() {
    _currentVehicle = null;
    _error = null;
  }

  // Limpar veículo atual com notificação
  void clearCurrentVehicle() {
    _currentVehicle = null;
    _error = null;
    notifyListeners();
  }

  // Liberar veículo atual
  Future<bool> releaseCurrentVehicle() async {
    if (_currentVehicle == null) return false;

    _isLoading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Atualizar odômetro
  Future<bool> updateOdometer(int newOdometer) async {
    if (_currentVehicle == null) return false;

    _isLoading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final vehicle = await _vehicleService.updateVehicleOdometer(
        _currentVehicle!.id,
        newOdometer,
      );

      if (vehicle != null) {
        _currentVehicle = vehicle;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'vehicle_${vehicle.id}', json.encode(vehicle.toJson()));

        _error = null;
        return true;
      } else {
        // Se falhar online, atualizar apenas localmente
        final updatedVehicle = _currentVehicle!.copyWith(odometer: newOdometer);
        _currentVehicle = updatedVehicle;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('vehicle_${updatedVehicle.id}',
            json.encode(updatedVehicle.toJson()));

        _error = null;
        return true;
      }
    } catch (e) {
      // Se falhar online, atualizar apenas localmente
      final updatedVehicle = _currentVehicle!.copyWith(odometer: newOdometer);
      _currentVehicle = updatedVehicle;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('vehicle_${updatedVehicle.id}',
            json.encode(updatedVehicle.toJson()));
      } catch (saveError) {
        print('Erro ao salvar veículo localmente: $saveError');
      }

      _error = null;
      return true;
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
