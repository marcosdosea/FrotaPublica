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
  }) async {
    try {
      // Converter para o formato esperado pela API
      final response = await ApiClient.post('Percurso/iniciar', {
        'idVeiculo': int.parse(vehicleId),
        'localPartida': origin,
        'localChegada': destination,
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
        // Vamos obter os detalhes do percurso finalizado
        final journeyResponse = await ApiClient.get('Percurso/${journeyId}');

        if (journeyResponse.statusCode == 200) {
          final journeyData = jsonDecode(journeyResponse.body);
          return true;
        }
        else{
          return false;
        }
      }
      else{
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Obter histórico de jornadas para um motorista
  Future<List<Journey>> getJourneyHistoryForDriver(String driverId) async {
    try {
      // A API não tem um endpoint específico para histórico de percursos
      // Seria necessário implementar na API esse endpoint, por enquanto
      // retornamos lista vazia
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
      // A API precisaria ter um endpoint para associar abastecimento ao percurso
      // Por enquanto, retornamos null
      return null;
    } catch (e) {
      print('Erro ao adicionar abastecimento à jornada: $e');
      return null;
    }
  }
}
