enum StatusSolicitacaoManutencao {
  pendente,
  emAndamento,
  concluida,
  rejeitada
}

class SolicitacaoManutencao {
  final String id;
  final String veiculoId;
  final String motoristId;
  final String descricao;
  final DateTime dataHora;
  final StatusSolicitacaoManutencao status;
  final String? observacoesTecnicas;
  final DateTime? dataConclusao;

  SolicitacaoManutencao({
    required this.id,
    required this.veiculoId,
    required this.motoristId,
    required this.descricao,
    required this.dataHora,
    required this.status,
    this.observacoesTecnicas,
    this.dataConclusao,
  });

  factory SolicitacaoManutencao.deJson(Map<String, dynamic> json) {
    return SolicitacaoManutencao(
      id: json['id'],
      veiculoId: json['vehicle_id'],
      motoristId: json['driver_id'],
      descricao: json['description'],
      dataHora: DateTime.parse(json['timestamp']),
      status: StatusSolicitacaoManutencao.values.byName(json['status']),
      observacoesTecnicas: json['technician_notes'],
      dataConclusao: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'])
          : null,
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'vehicle_id': veiculoId,
      'driver_id': motoristId,
      'description': descricao,
      'timestamp': dataHora.toIso8601String(),
      'status': status.name,
      'technician_notes': observacoesTecnicas,
      'completion_date': dataConclusao?.toIso8601String(),
    };
  }
}
