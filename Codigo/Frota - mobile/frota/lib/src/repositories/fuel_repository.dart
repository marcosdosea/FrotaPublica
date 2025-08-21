import 'dart:convert';
import '../models/fuel_refill.dart';
import '../utils/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FuelRepository {
  // Lista de abastecimentos mockados (manter para compatibilidade com funções existentes)
  final List<FuelRefill> _mockFuelRefills = [];

  // Chave base para armazenamento local do total de litros abastecidos por percurso
  static const String _totalLitersKey = 'total_liters_journey_';

  // Registrar um novo abastecimento na API
  Future<FuelRefill?> registerFuelRefill({
    required String journeyId,
    required String vehicleId,
    required String driverId,
    required String gasStation,
    required double liters,
    double? totalCost,
    required int odometerReading,
  }) async {
    try {
      final response = await ApiClient.post('Abastecimento', {
        'idVeiculo': int.parse(vehicleId),
        'idFornecedor': int.parse(gasStation),
        'data': DateTime.now().toIso8601String(),
        'valorLitro': totalCost != null && liters > 0 ? totalCost / liters : 0,
        'litros': liters,
        'kmAtual': odometerReading,
        'observacoes': '',
        'idPercurso': journeyId != '0' ? int.parse(journeyId) : null,
      });

      if (response.statusCode == 200) {
        print('Abastecimento registrado com sucesso: ${response.body}');
        final data = jsonDecode(response.body);

        // Persistir o total de litros abastecidos para o percurso
        await addLitersToJourneyTotal(journeyId, liters);

        // Extrair o ID do abastecimento da resposta JSON
        String abastecimentoId;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('idAbastecimento')) {
            abastecimentoId = data['idAbastecimento'].toString();
          } else if (data.containsKey('abastecimento') &&
              data['abastecimento'] is Map &&
              data['abastecimento'].containsKey('id')) {
            abastecimentoId = data['abastecimento']['id'].toString();
          } else if (data.containsKey('Abastecimento') &&
              data['Abastecimento'] is Map &&
              data['Abastecimento'].containsKey('id')) {
            abastecimentoId = data['Abastecimento']['id'].toString();
          } else if (data.containsKey('IdAbastecimento')) {
            abastecimentoId = data['IdAbastecimento'].toString();
          } else {
            print(
                'Aviso: ID do abastecimento não encontrado na resposta. Usando ID temporário.');
            abastecimentoId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
          }
        } else {
          print('Aviso: Resposta em formato inesperado. Usando ID temporário.');
          abastecimentoId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
        }

        final newFuelRefill = FuelRefill(
          id: abastecimentoId,
          journeyId: journeyId,
          vehicleId: vehicleId,
          driverId: driverId,
          gasStation: gasStation,
          liters: liters,
          totalCost: totalCost,
          odometerReading: odometerReading,
          timestamp: DateTime.now(),
        );

        // Adicionar ao cache local para compatibilidade com outras funções
        _mockFuelRefills.add(newFuelRefill);



        return newFuelRefill;
      } else {
        final errorResponse = response.body;
        print(
            'Erro ao registrar abastecimento. Status: ${response.statusCode}');
        print('Mensagem: $errorResponse');

        // Verificar se a mensagem de erro contém informações sobre o odômetro
        if (errorResponse.contains("odômetro informado") &&
            errorResponse.contains("não pode ser menor")) {
          throw Exception(errorResponse);
        }
        // Verificar se a mensagem de erro contém informações sobre o fornecedor
        else if (errorResponse.contains("selecionar um posto")) {
          throw Exception("É necessário selecionar um posto de combustível");
        }

        return null;
      }
    } catch (e) {
      print('Exceção ao registrar abastecimento: $e');
      rethrow;
    }
  }

  // Adiciona litros ao total persistido para o percurso
  Future<void> addLitersToJourneyTotal(String journeyId, double liters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_totalLitersKey$journeyId';
      final current = prefs.getDouble(key) ?? 0.0;
      await prefs.setDouble(key, current + liters);
    } catch (e) {
      print('Erro ao somar litros ao total do percurso: $e');
    }
  }

  // Obtém o total de litros abastecidos para o percurso
  Future<double> getTotalLitersForJourney(String journeyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_totalLitersKey$journeyId';
      return prefs.getDouble(key) ?? 0.0;
    } catch (e) {
      print('Erro ao obter total de litros do percurso: $e');
      return 0.0;
    }
  }

  // Zera o total de litros abastecidos para o percurso
  Future<void> clearTotalLitersForJourney(String journeyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_totalLitersKey$journeyId';
      await prefs.remove(key);
    } catch (e) {
      print('Erro ao zerar total de litros do percurso: $e');
    }
  }

  // Obter abastecimentos para um veículo específico
  Future<List<FuelRefill>> getFuelRefillsForVehicle(String vehicleId) async {
    return _mockFuelRefills
        .where((refill) => refill.vehicleId == vehicleId)
        .toList();
  }

  // Obter abastecimentos para uma jornada específica
  Future<List<FuelRefill>> getFuelRefillsForJourney(String journeyId) async {
    return _mockFuelRefills
        .where((refill) => refill.journeyId == journeyId)
        .toList();
  }

  // Calcular total de combustível abastecido para um veículo
  Future<double> getTotalFuelCostForVehicle(String vehicleId) async {
    final refills =
        _mockFuelRefills.where((refill) => refill.vehicleId == vehicleId);

    if (refills.isEmpty) {
      return 0.0;
    }

    return refills
        .map((refill) => refill.totalCost ?? 0.0)
        .reduce((value, element) => value + element);
  }
}
