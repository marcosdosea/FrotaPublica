enum MaintenanceStatus {
  pending,
  inProgress,
  completed,
  rejected
}

class MaintenanceRequest {
  final String id;
  final String vehicleId;
  final String driverId;
  final String description;
  final DateTime timestamp;
  final MaintenanceStatus status;
  final String? technicianNotes;
  final DateTime? completionDate;

  MaintenanceRequest({
    required this.id,
    required this.vehicleId,
    required this.driverId,
    required this.description,
    required this.timestamp,
    required this.status,
    this.technicianNotes,
    this.completionDate,
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      driverId: json['driver_id'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      status: MaintenanceStatus.values.byName(json['status']),
      technicianNotes: json['technician_notes'],
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'technician_notes': technicianNotes,
      'completion_date': completionDate?.toIso8601String(),
    };
  }
}
