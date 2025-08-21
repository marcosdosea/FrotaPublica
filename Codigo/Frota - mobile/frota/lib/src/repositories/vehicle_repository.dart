import 'dart:convert';
import '../models/vehicle.dart';
import '../utils/api_client.dart';

class VehicleRepository {
  // Método privado para buscar o nome do modelo do veículo
  Future<String> _getVehicleModelName(String vehicleId) async {
    try {
      final response = await ApiClient.get('ModeloVeiculo/$vehicleId');
      if (response.statusCode == 200) {
        return response.body.replaceAll('"', ''); // Remove as aspas da string
      }
      return 'Modelo não encontrado';
    } catch (e) {
      print('Erro ao buscar nome do modelo do veículo: $e');
      return 'Erro ao buscar modelo';
    }
  }

  // Obter todos os veículos disponíveis
  Future<List<Vehicle>> getAvailableVehicles(
      int? unidadeAdministrativaId) async {
    try {
      // Usando o novo endpoint conforme especificado
      print('Buscando veículos disponíveis da API...');
      final response = await ApiClient.get('Veiculo/disponiveis');
      print('Status da resposta: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print(
            'Resposta recebida: ${responseBody.substring(0, responseBody.length > 100 ? 100 : responseBody.length)}...');

        // Decode a resposta como Map, não como List
        final Map<String, dynamic> responseData = jsonDecode(responseBody);

        // Acessa a lista de veículos dentro da propriedade "veiculos"
        final List<dynamic> data = responseData['veiculos'];
        print('Quantidade de veículos encontrados: ${data.length}');

        // Processamento mais seguro com tratamento de exceção por veículo
        final List<Vehicle> vehicles = [];
        for (var i = 0; i < data.length; i++) {
          try {
            final vehicleJson = data[i];
            print(
                'Processando veículo ${i + 1}/${data.length}: ${vehicleJson['placa'] ?? 'sem placa'}');

            print(
                'ID: ${vehicleJson['id']}, Modelo: ${vehicleJson['idModeloVeiculo']}, Status: ${vehicleJson['status']}');

            vehicleJson['id'] = vehicleJson['id'].toString();

            final vehicle = Vehicle.fromJson(vehicleJson);

            // Buscar o nome do modelo do veículo
            final modelName = await _getVehicleModelName(vehicle.id);
            final updatedVehicle = vehicle.copyWith(model: modelName);

            vehicles.add(updatedVehicle);
            print('Veículo ${vehicle.licensePlate} processado com sucesso');
          } catch (e, st) {
            print('ERRO ao processar veículo $i: $e');
            print('Stack trace: $st');
          }
        }

        print('Total de veículos processados com sucesso: ${vehicles.length}');
        return vehicles;
      } else {
        print(
            'Erro ao buscar veículos. Status: ${response.statusCode}, Resposta: ${response.body}');
        return [];
      }
    } catch (e, stacktrace) {
      print('Erro ao obter veículos disponíveis: $e');
      print('Stacktrace: $stacktrace');
      return [];
    }
  }

  // Obter todos os veículos
  Future<List<Vehicle>> getAllVehicles() async {
    try {
      final response = await ApiClient.get('Veiculos');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((vehicleJson) => Vehicle.fromJson(vehicleJson))
            .toList();
      }

      return [];
    } catch (e) {
      print('Erro ao obter todos os veículos: $e');
      return [];
    }
  }

  // Obter um veículo específico por ID
  Future<Vehicle?> getVehicleById(String id) async {
    try {
      final response = await ApiClient.get('Veiculo/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final vehicle = Vehicle.fromJson(data);

        final modelName = await _getVehicleModelName(id);
        return vehicle.copyWith(model: modelName);
      }

      return null;
    } catch (e) {
      print('Erro ao obter veículo por ID: $e');
      return null;
    }
  }

  // Atualizar o status de disponibilidade de um veículo
  Future<Vehicle?> updateVehicleAvailability(
      String id, bool isAvailable) async {
    try {
      final response = await ApiClient.put(
          'Veiculos/$id/disponibilidade', {'disponivel': isAvailable});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Vehicle.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Erro ao atualizar disponibilidade do veículo: $e');
      throw Exception('Veículo não encontrado');
    }
  }

  // Atualizar o odômetro de um veículo
  Future<Vehicle?> updateVehicleOdometer(String id, int newOdometer) async {
    try {
      final response = await ApiClient.put(
          'Veiculos/$id/kilometragem', {'kmAtual': newOdometer});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Vehicle.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Erro ao atualizar odômetro do veículo: $e');
      throw Exception('Veículo não encontrado');
    }
  }

  // Atribuir um veículo a um motorista
  Future<Vehicle?> assignVehicleToDriver(
      String vehicleId, String driverId) async {
    try {
      final response = await ApiClient.put(
          'Veiculos/$vehicleId/motorista', {'motoristaId': driverId});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Vehicle.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Erro ao atribuir veículo ao motorista: $e');
      throw Exception('Veículo não encontrado');
    }
  }

  // Liberar um veículo (remover atribuição de motorista)
  Future<Vehicle?> releaseVehicle(String vehicleId) async {
    try {
      final response = await ApiClient.delete('Veiculos/$vehicleId/motorista');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Vehicle.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Erro ao liberar veículo: $e');
      throw Exception('Veículo não encontrado');
    }
  }
}
