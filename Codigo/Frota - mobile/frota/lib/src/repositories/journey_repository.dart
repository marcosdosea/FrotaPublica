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
      final response = await ApiClient.get('Percurso/atual');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Verifica se há um percurso em andamento
        if (data['emPercurso'] == true && data['percurso'] != null) {
          return Journey.fromJson(data['percurso']);
        }
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
    String? reason,
    double? originLatitude,
    double? originLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
  }) async {
    try {
      final response = await ApiClient.post('Percurso/iniciar', {
        'idVeiculo': int.parse(vehicleId),
        'localPartida': origin,
        'latitudePartida': originLatitude,
        'longitudePartida': originLongitude,
        'localChegada': destination,
        'latitudeChegada': destinationLatitude,
        'longitudeChegada': destinationLongitude,
        'odometroInicial': initialOdometer,
        'motivo': reason ?? ''
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Verifica se é um percurso existente ou um novo
        if (data['emPercurso'] == true && data['percurso'] != null) {
          // É um percurso já em andamento
          return Journey.fromJson(data['percurso']);
        } else if (data['percurso'] != null) {
          // É um novo percurso
          return Journey.fromJson(data['percurso']);
        }
      }

      return null;
    } catch (e) {
      print('Erro ao iniciar jornada: $e');
      return null;
    }
  }

  // Finalizar uma jornada
  Future<bool> finishJourney({
    required String journeyId,
    required int finalOdometer,
  }) async {
    try {
      final response = await ApiClient.post('Percurso/finalizar',
          {'idPercurso': int.parse(journeyId), 'odometroFinal': finalOdometer});

      if (response.statusCode == 200) {
        final journeyResponse = await ApiClient.get('Percurso/${journeyId}');

        if (journeyResponse.statusCode == 200) {
          final journeyData = jsonDecode(journeyResponse.body);
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Obter histórico de jornadas para um motorista
  Future<List<Journey>> getJourneyHistoryForDriver(String driverId) async {
    try {
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
      return null;
    } catch (e) {
      print('Erro ao adicionar abastecimento à jornada: $e');
      return null;
    }
  }
}
