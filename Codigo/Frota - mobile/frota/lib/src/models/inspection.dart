enum InspectionType { departure, arrival }

class Inspection {
  final String? id;
  final String vehicleId;
  final String type; // "Retirada" ou "Entrega"
  final String? problems;
  final DateTime timestamp;

  Inspection({
    this.id,
    required this.vehicleId,
    required this.type,
    this.problems,
    required this.timestamp,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id']?.toString(),
      vehicleId: json['vehicleId'].toString(),
      type: json['tipo'],
      problems: json['problemas'],
      timestamp:
          DateTime.parse(json['dataHora'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idVeiculo': int.parse(vehicleId),
      'tipo': type,
      'problemas': problems ?? '',
    };
  }

  Inspection copyWith({
    String? id,
    String? vehicleId,
    String? type,
    String? problems,
    DateTime? timestamp,
  }) {
    return Inspection(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      problems: problems ?? this.problems,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
