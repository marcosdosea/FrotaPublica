import '../repositories/vehicle_repository.dart';
import '../models/vehicle.dart';

class VehicleService {
  final VehicleRepository _vehicleRepository = VehicleRepository();

  // Obter veículos disponíveis
  Future<List<Vehicle>> getAvailableVehicles(
      {int? unidadeAdministrativaId}) async {
    try {
      return await _vehicleRepository.getAvailableVehicles(null);
    } catch (e) {
      print('Erro no serviço ao obter veículos disponíveis: $e');
      return [];
    }
  }

  // Obter veículo por ID
  Future<Vehicle?> getVehicleById(String id) async {
    try {
      return await _vehicleRepository.getVehicleById(id);
    } catch (e) {
      print('Erro no serviço ao obter veículo por ID: $e');
      return null;
    }
  }

  // Atualizar odômetro
  Future<Vehicle?> updateVehicleOdometer(String id, int newOdometer) async {
    try {
      return await _vehicleRepository.updateVehicleOdometer(id, newOdometer);
    } catch (e) {
      print('Erro no serviço ao atualizar odômetro: $e');
      return null;
    }
  }

  // Atribuir veículo a motorista
  Future<Vehicle?> assignVehicleToDriver(
      String vehicleId, String driverId) async {
    try {
      return await _vehicleRepository.assignVehicleToDriver(
          vehicleId, driverId);
    } catch (e) {
      print('Erro no serviço ao atribuir veículo ao motorista: $e');
      return null;
    }
  }

  // Liberar veículo
  Future<Vehicle?> releaseVehicle(String vehicleId) async {
    try {
      return await _vehicleRepository.releaseVehicle(vehicleId);
    } catch (e) {
      print('Erro no serviço ao liberar veículo: $e');
      return null;
    }
  }
}
