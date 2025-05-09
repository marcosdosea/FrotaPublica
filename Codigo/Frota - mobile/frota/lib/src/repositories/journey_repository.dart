import 'dart:convert';
import '../models/journey.dart';
import '../utils/api_client.dart';

class JourneyRepository {
  // Lista de jornadas mockadas
  final List<Journey> _mockJourneys = [
    Journey(
      id: '1',
      vehicleId: '1',
      driverId: '1',
      origin: 'Itabaiana',
      destination: 'Areia Branca',
      initialOdometer: 12345,
      departureTime: DateTime.now().subtract(const Duration(hours: 1)),
      isActive: true,
    ),
  ];

  // Obter jornada ativa para um motorista
  Future<Journey?> getActiveJourneyForDriver(String driverId) async {
    try {
      final response =
          await ApiClient.get('Percursos/ativo/motorista/$driverId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Journey.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Erro ao obter jornada ativa: $e');
      return null;
    }
  }

  // Iniciar uma nova jornada
  Future<Journey?> startJourney({
    required String vehicleId,
    required String driverId,
    required String origin,
    required String destination,
    required int initialOdometer,
  }) async {
    try {
      final response = await ApiClient.post('Percursos', {
        'veiculoId': vehicleId,
        'motoristaId': driverId,
        'origem': origin,
        'destino': destination,
        'kmInicial': initialOdometer,
        'dataHoraSaida': DateTime.now().toIso8601String(),
        'ativo': true
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Journey.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Erro ao iniciar jornada: $e');
      return null;
    }
  }

  // Finalizar uma jornada
  Future<Journey?> finishJourney({
    required String journeyId,
    required int finalOdometer,
  }) async {
    try {
      final response = await ApiClient.put('Percursos/$journeyId/finalizar', {
        'kmFinal': finalOdometer,
        'dataHoraChegada': DateTime.now().toIso8601String(),
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Journey.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Erro ao finalizar jornada: $e');
      return null;
    }
  }

  // Obter histórico de jornadas para um motorista
  Future<List<Journey>> getJourneyHistoryForDriver(String driverId) async {
    try {
      final response = await ApiClient.get('Percursos/motorista/$driverId');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((journeyJson) => Journey.fromJson(journeyJson))
            .toList();
      }

      return [];
    } catch (e) {
      print('Erro ao obter histórico de jornadas: $e');
      return [];
    }
  }

  // Adicionar ID de abastecimento a uma jornada
  Future<Journey?> addFuelRefillToJourney(
      String journeyId, String fuelRefillId) async {
    try {
      final response = await ApiClient.put(
          'Percursos/$journeyId/abastecimento/$fuelRefillId', {});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Journey.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Erro ao adicionar abastecimento à jornada: $e');
      return null;
    }
  }
}
