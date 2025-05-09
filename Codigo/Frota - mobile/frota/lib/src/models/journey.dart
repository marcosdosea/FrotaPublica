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
  });

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehicle_id'] ?? json['veiculoId']?.toString() ?? '',
      driverId: json['driver_id'] ?? json['motoristaId']?.toString() ?? '',
      origin: json['origin'] ?? json['origem'] ?? '',
      destination: json['destination'] ?? json['destino'] ?? '',
      initialOdometer: json['initial_odometer'] ?? json['kmInicial'] ?? 0,
      finalOdometer: json['final_odometer'] ?? json['kmFinal'],
      departureTime: json['departure_time'] != null
          ? DateTime.parse(json['departure_time'])
          : json['dataHoraSaida'] != null
              ? DateTime.parse(json['dataHoraSaida'])
              : DateTime.now(),
      arrivalTime: json['arrival_time'] != null
          ? DateTime.parse(json['arrival_time'])
          : json['dataHoraChegada'] != null
              ? DateTime.parse(json['dataHoraChegada'])
              : null,
      isActive: json['is_active'] ?? json['ativo'] ?? true,
      distance: json['distance'] ?? json['distanciaPercorrida']?.toDouble(),
      fuelRefillIds: json['fuel_refill_ids'] != null
          ? List<String>.from(json['fuel_refill_ids'])
          : json['abastecimentoIds'] != null
              ? List<String>.from(
                  json['abastecimentoIds'].map((id) => id.toString()))
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'veiculoId': vehicleId,
      'motoristaId': driverId,
      'origem': origin,
      'destino': destination,
      'kmInicial': initialOdometer,
      'kmFinal': finalOdometer,
      'dataHoraSaida': departureTime.toIso8601String(),
      'dataHoraChegada': arrivalTime?.toIso8601String(),
      'ativo': isActive,
      'distanciaPercorrida': distance,
      'abastecimentoIds': fuelRefillIds,
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
}
