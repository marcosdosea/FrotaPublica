enum InspectionType { departure, arrival }

class Inspection {
  final String id;
  final String journeyId;
  final String vehicleId;
  final String driverId;
  final InspectionType type;
  final String? problems;
  final DateTime timestamp;
  final bool isCompleted;

  Inspection({
    required this.id,
    required this.journeyId,
    required this.vehicleId,
    required this.driverId,
    required this.type,
    this.problems,
    required this.timestamp,
    required this.isCompleted,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    InspectionType determineType(dynamic typeValue) {
      if (typeValue is String) {
        if (typeValue.toLowerCase() == 'departure' ||
            typeValue.toLowerCase() == 'saida') {
          return InspectionType.departure;
        } else {
          return InspectionType.arrival;
        }
      } else if (typeValue is int) {
        return typeValue == 0
            ? InspectionType.departure
            : InspectionType.arrival;
      }
      return InspectionType.departure;
    }

    return Inspection(
      id: json['id']?.toString() ?? '',
      journeyId: json['journey_id'] ?? json['percursoId']?.toString() ?? '',
      vehicleId: json['vehicle_id'] ?? json['veiculoId']?.toString() ?? '',
      driverId: json['driver_id'] ?? json['motoristaId']?.toString() ?? '',
      type: json['type'] != null
          ? determineType(json['type'])
          : json['tipo'] != null
              ? determineType(json['tipo'])
              : InspectionType.departure,
      problems: json['problems'] ?? json['problemas'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : json['dataHora'] != null
              ? DateTime.parse(json['dataHora'])
              : DateTime.now(),
      isCompleted: json['is_completed'] ?? json['concluida'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'percursoId': journeyId,
      'veiculoId': vehicleId,
      'motoristaId': driverId,
      'tipo': type == InspectionType.departure ? 'Saida' : 'Entrega',
      'problemas': problems,
      'dataHora': timestamp.toIso8601String(),
      'concluida': isCompleted,
    };
  }

  Inspection copyWith({
    String? id,
    String? journeyId,
    String? vehicleId,
    String? driverId,
    InspectionType? type,
    String? problems,
    DateTime? timestamp,
    bool? isCompleted,
  }) {
    return Inspection(
      id: id ?? this.id,
      journeyId: journeyId ?? this.journeyId,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      type: type ?? this.type,
      problems: problems ?? this.problems,
      timestamp: timestamp ?? this.timestamp,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
