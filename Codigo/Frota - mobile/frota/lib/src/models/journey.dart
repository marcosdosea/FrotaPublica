import 'package:intl/intl.dart';

class Journey {
  final String id;
  final String vehicleId;
  final String driverId;
  final String origin;
  final String destination;
  final int initialOdometer;
  final int? finalOdometer;
  final DateTime departureTime;
  final DateTime? arrivalTime;
  final bool isActive;
  final double? distance;
  final List<String>? fuelRefillIds;
  final String? reason;
  final double? originLatitude;
  final double? originLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;

  Journey({
    required this.id,
    required this.vehicleId,
    required this.driverId,
    required this.origin,
    required this.destination,
    required this.initialOdometer,
    this.finalOdometer,
    required this.departureTime,
    this.arrivalTime,
    required this.isActive,
    this.distance,
    this.fuelRefillIds,
    this.reason,
    this.originLatitude,
    this.originLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
  });

  factory Journey.fromJson(Map<String, dynamic> json) {
    // Verificar se a data de retorno é a data mínima (indica percurso ativo)
    final DateTime? dataRetorno = json['dataHoraRetorno'] != null
        ? DateTime.parse(json['dataHoraRetorno'])
        : null;

    // Se for DateTime.MinValue (usado pela API para indicar percursos ativos),
    // consideramos como null
    final bool isMinDate = dataRetorno?.year == 1 &&
        dataRetorno?.month == 1 &&
        dataRetorno?.day == 1;

    return Journey(
      id: json['id']?.toString() ?? '',
      vehicleId: json['idVeiculo']?.toString() ?? '',
      driverId: json['idPessoa']?.toString() ?? '',
      origin: json['localPartida'] ?? '',
      destination: json['localChegada'] ?? '',
      initialOdometer: json['odometroInicial'] ?? 0,
      finalOdometer: isMinDate ? null : json['odometroFinal'],
      departureTime: json['dataHoraSaida'] != null
          ? DateTime.parse(json['dataHoraSaida'])
          : DateTime.now(),
      arrivalTime: isMinDate ? null : dataRetorno,
      isActive: isMinDate,
      reason: json['motivo'],
      // Coordenadas de origem
      originLatitude: json['latitudePartida']?.toDouble(),
      originLongitude: json['longitudePartida']?.toDouble(),
      // Coordenadas de destino
      destinationLatitude: json['latitudeChegada']?.toDouble(),
      destinationLongitude: json['longitudeChegada']?.toDouble(),
      // Esses campos podem não estar disponíveis na API
      distance: null,
      fuelRefillIds: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idVeiculo': vehicleId,
      'idPessoa': driverId,
      'localPartida': origin,
      'localChegada': destination,
      'odometroInicial': initialOdometer,
      'odometroFinal': finalOdometer,
      'dataHoraSaida': departureTime.toIso8601String(),
      'dataHoraRetorno': arrivalTime?.toIso8601String(),
      'motivo': reason,
      'latitudePartida': originLatitude,
      'longitudePartida': originLongitude,
      'latitudeChegada': destinationLatitude,
      'longitudeChegada': destinationLongitude,
    };
  }

  Journey copyWith({
    String? id,
    String? vehicleId,
    String? driverId,
    String? origin,
    String? destination,
    int? initialOdometer,
    int? finalOdometer,
    DateTime? departureTime,
    DateTime? arrivalTime,
    bool? isActive,
    double? distance,
    List<String>? fuelRefillIds,
    String? reason,
    double? originLatitude,
    double? originLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
  }) {
    return Journey(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      initialOdometer: initialOdometer ?? this.initialOdometer,
      finalOdometer: finalOdometer ?? this.finalOdometer,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      isActive: isActive ?? this.isActive,
      distance: distance ?? this.distance,
      fuelRefillIds: fuelRefillIds ?? this.fuelRefillIds,
      reason: reason ?? this.reason,
      originLatitude: originLatitude ?? this.originLatitude,
      originLongitude: originLongitude ?? this.originLongitude,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
    );
  }

  // Formatação de data para exibição
  String get formattedDepartureTime {
    return DateFormat('dd/MM/yyyy HH:mm').format(departureTime);
  }

  // Cálculo de progresso da jornada (para UI)
  double get progress {
    if (!isActive || arrivalTime != null) return 1.0;

    // Estimativa baseada no tempo (simplificada)
    final now = DateTime.now();
    final totalEstimatedDuration =
        const Duration(hours: 2); // Estimativa fixa para exemplo
    final elapsedDuration = now.difference(departureTime);

    return (elapsedDuration.inMinutes / totalEstimatedDuration.inMinutes)
        .clamp(0.0, 1.0);
  }

  // Duração da jornada
  String get duration {
    if (!isActive) return '0:00 h';

    final end = arrivalTime ?? DateTime.now();
    final difference = end.difference(departureTime);

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    return '$hours:${minutes.toString().padLeft(2, '0')} h';
  }

  // Verifica se tem coordenadas válidas
  bool get hasValidCoordinates {
    return originLatitude != null &&
        originLongitude != null &&
        destinationLatitude != null &&
        destinationLongitude != null;
  }

  // Getters para compatibilidade com o map_screen.dart
  double? get departureLatitude => originLatitude;
  double? get departureLongitude => originLongitude;
  double? get arrivalLatitude => destinationLatitude;
  double? get arrivalLongitude => destinationLongitude;
  String? get departureLocation => origin;
  String? get arrivalLocation => destination;
}
