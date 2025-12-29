import 'dart:convert';
import '../utils/api_client.dart';

class RouteService {
  /// Obtém a rota de um percurso através da API
  /// Retorna o JSON completo da resposta do Google Maps Directions API
  Future<String?> getRouteForJourney(String journeyId) async {
    try {
      final response = await ApiClient.get('Rota/percurso/$journeyId');

      if (response.statusCode == 200) {
        // A resposta já é o JSON da rota
        return response.body;
      } else if (response.statusCode == 404) {
        print('RouteService: Percurso não encontrado');
        return null;
      } else {
        print('RouteService: Erro ao obter rota (StatusCode: ${response.statusCode})');
        return null;
      }
    } catch (e) {
      print('RouteService: Erro ao obter rota: $e');
      return null;
    }
  }

  /// Processa o JSON da rota e extrai informações úteis
  Map<String, dynamic>? parseRouteJson(String routeJson) {
    try {
      final data = json.decode(routeJson);
      
      if (data['status'] == 'OK' && (data['routes'] as List).isNotEmpty) {
        final route = data['routes'][0];
        final leg = route['legs'][0];
        
        return {
          'status': 'OK',
          'distance': leg['distance']['text'],
          'duration': leg['duration']['text'],
          'polyline': route['overview_polyline']['points'],
          'fullJson': routeJson, // Manter o JSON completo para uso futuro
        };
      }
      
      return {
        'status': data['status'] ?? 'UNKNOWN_ERROR',
        'error': data['error_message'] ?? 'Erro desconhecido ao processar rota',
      };
    } catch (e) {
      print('RouteService: Erro ao processar JSON da rota: $e');
      return null;
    }
  }
}

