import 'dart:convert';
import 'maintenance_priority.dart';

class MaintenanceRequest {
  final String id;
  final String vehicleId;
  final String driverId;
  final String description;
  final DateTime timestamp;
  final String status;
  final String? technicianNotes;
  final DateTime? completionDate;
  final MaintenancePriority priority;

  MaintenanceRequest({
    required this.id,
    required this.vehicleId,
    required this.driverId,
    required this.description,
    required this.timestamp,
    required this.status,
    this.technicianNotes,
    this.completionDate,
    this.priority = MaintenancePriority.media,
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'].toString(),
      vehicleId: json['idVeiculo'].toString(),
      driverId: json['idPessoa'].toString(),
      description: json['descricaoProblema'],
      timestamp: DateTime.parse(json['dataSolicitacao']),
      status: json['status'] ?? 'Pendente',
      technicianNotes: json['observacoesTecnico'],
      completionDate: json['dataConclusao'] != null
          ? DateTime.parse(json['dataConclusao'])
          : null,
      priority: json['prioridade'] != null
          ? MaintenancePriority.fromCode(json['prioridade'])
          : MaintenancePriority.media,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idVeiculo': int.parse(vehicleId),
      'idPessoa': int.parse(driverId),
      'descricaoProblema': description,
      'dataSolicitacao': timestamp.toIso8601String(),
      'status': status,
      'observacoesTecnico': technicianNotes,
      'dataConclusao': completionDate?.toIso8601String(),
      'prioridade': priority.code,
    };
  }
}
