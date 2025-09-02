class Vehicle {
  final String id;
  final String model;
  final String licensePlate;
  final int odometer;
  final String? imageUrl;
  final bool isAvailable;
  final String? currentDriverId;
  final List<String>? maintenanceIssues;
  final double? fuelSpent;
  final int? distanceTraveled;
  final double? fuelEfficiency;
  final int? unidadeAdministrativaId;

  Vehicle({
    required this.id,
    required this.model,
    required this.licensePlate,
    required this.odometer,
    this.imageUrl,
    required this.isAvailable,
    this.currentDriverId,
    this.maintenanceIssues,
    this.fuelSpent,
    this.distanceTraveled,
    this.fuelEfficiency,
    this.unidadeAdministrativaId,
  });

  factory Vehicle.fromJson(dynamic json) {
    try {
      // Log para depuração
      print(
          'Convertendo veículo: ${json.toString().substring(0, json.toString().length > 100 ? 100 : json.toString().length)}...');

      // Verificando status e convertendo para isAvailable
      final String status = json['status'] ?? '';
      print('Status do veículo: $status');
      final bool disponivel = status == 'D'; // 'D' indica disponível

      // Tratamento do ID para garantir formato string
      final String veiculoId = json['id']?.toString() ?? '';
      print('ID do veículo: $veiculoId');

      // Tratamento para a placa
      final String placa =
          json['license_plate'] ?? json['placa'] ?? 'Sem placa';
      print('Placa do veículo: $placa');

      // CORREÇÃO: Tratamento correto para o odômetro
      int odometro = 0;

      // Primeiro, tenta pegar diretamente do campo 'odometro'
      if (json['odometro'] != null) {
        if (json['odometro'] is int) {
          odometro = json['odometro'];
        } else {
          odometro = int.tryParse(json['odometro'].toString()) ?? 0;
        }
      }
      // Se não encontrar 'odometro', tenta outros possíveis nomes de campo
      else if (json['odometer'] != null) {
        if (json['odometer'] is int) {
          odometro = json['odometer'];
        } else {
          odometro = int.tryParse(json['odometer'].toString()) ?? 0;
        }
      }

      print('Odômetro do veículo: $odometro');

      // Tratamento para o modelo do veículo
      String modelo = '';
      print('DEBUG - Campos disponíveis: ${json.keys.toList()}');

      if (json['model'] != null) {
        modelo = json['model'].toString();
        print('DEBUG - Modelo encontrado em "model": $modelo');
      } else if (json['modelo'] != null) {
        modelo = json['modelo'].toString();
        print('DEBUG - Modelo encontrado em "modelo": $modelo');
      } else if (json['idModeloVeiculoNavigation'] != null &&
          json['idModeloVeiculoNavigation'] is Map &&
          json['idModeloVeiculoNavigation']['descricao'] != null) {
        modelo = json['idModeloVeiculoNavigation']['descricao'];
        print('DEBUG - Modelo encontrado em navigation: $modelo');
      } else {
        // Tentativa de identificar modelo pelo ID
        final modeloId = json['idModeloVeiculo']?.toString() ?? '';
        if (modeloId.isNotEmpty) {
          modelo = 'Modelo ID: $modeloId';
          print('DEBUG - Modelo criado com ID: $modelo');
        } else {
          modelo = 'Modelo desconhecido';
          print('DEBUG - Modelo desconhecido');
        }
      }
      print('Modelo do veículo: $modelo');

      return Vehicle(
        id: veiculoId,
        model: modelo,
        licensePlate: placa,
        odometer: odometro, // Usando a variável corrigida
        imageUrl: json['image_url'] ?? json['fotoUrl'],
        isAvailable: json['is_available'] ?? json['disponivel'] ?? disponivel,
        currentDriverId:
            json['current_driver_id'] ?? json['motoristaAtualId']?.toString(),
        maintenanceIssues: json['maintenance_issues'] != null
            ? List<String>.from(json['maintenance_issues'])
            : null,
        fuelSpent: _parseDouble(json['fuel_spent']) ??
            _parseDouble(json['combustivelGasto']),
        distanceTraveled: _parseInt(json['distance_traveled']) ??
            _parseInt(json['kmPercorrido']),
        fuelEfficiency: _parseDouble(json['fuel_efficiency']) ??
            _parseDouble(json['eficienciaCombustivel']),
        unidadeAdministrativaId: _parseInt(json['unidadeAdministrativaId']) ??
            _parseInt(json['idUnidadeAdministrativa']),
      );
    } catch (e, st) {
      print('ERRO ao converter veículo: $e');
      print('Stack trace: $st');

      // Retornar um veículo com valores padrão para evitar erro
      return Vehicle(
        id: json['id']?.toString() ?? 'erro',
        model: 'Erro de conversão',
        licensePlate: json['placa']?.toString() ?? 'Erro',
        odometer: 0,
        isAvailable: false,
        imageUrl: null,
      );
    }
  }

  // Métodos auxiliares para parsing seguro
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Vehicle copyWith({
    String? id,
    String? model,
    String? licensePlate,
    int? odometer,
    String? imageUrl,
    bool? isAvailable,
    String? currentDriverId,
    List<String>? maintenanceIssues,
    double? fuelSpent,
    int? distanceTraveled,
    double? fuelEfficiency,
    int? unidadeAdministrativaId,
  }) {
    return Vehicle(
      id: id ?? this.id,
      model: model ?? this.model,
      licensePlate: licensePlate ?? this.licensePlate,
      odometer: odometer ?? this.odometer,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      currentDriverId: currentDriverId ?? this.currentDriverId,
      maintenanceIssues: maintenanceIssues ?? this.maintenanceIssues,
      fuelSpent: fuelSpent ?? this.fuelSpent,
      distanceTraveled: distanceTraveled ?? this.distanceTraveled,
      fuelEfficiency: fuelEfficiency ?? this.fuelEfficiency,
      unidadeAdministrativaId:
          unidadeAdministrativaId ?? this.unidadeAdministrativaId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'license_plate': licensePlate,
      'odometro': odometer,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'current_driver_id': currentDriverId,
      'maintenance_issues': maintenanceIssues,
      'fuel_spent': fuelSpent,
      'distance_traveled': distanceTraveled,
      'fuel_efficiency': fuelEfficiency,
      'unidadeAdministrativaId': unidadeAdministrativaId,
    };
  }
}
