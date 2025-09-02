import 'package:intl/intl.dart';

enum TipoVistoria {
  saida,
  chegada
}

class Vistoria {
  final String id;
  final String percursoId;
  final String veiculoId;
  final String motoristaId;
  final TipoVistoria tipo;
  final String? problemas;
  final DateTime dataHora;
  final bool concluida;

  Vistoria({
    required this.id,
    required this.percursoId,
    required this.veiculoId,
    required this.motoristaId,
    required this.tipo,
    this.problemas,
    required this.dataHora,
    required this.concluida,
  });

  factory Vistoria.deJson(Map<String, dynamic> json) {
    return Vistoria(
      id: json['id'],
      percursoId: json['journey_id'],
      veiculoId: json['vehicle_id'],
      motoristaId: json['driver_id'],
      tipo: TipoVistoria.values.byName(json['type']),
      problemas: json['problems'],
      dataHora: DateTime.parse(json['timestamp']),
      concluida: json['is_completed'],
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'journey_id': percursoId,
      'vehicle_id': veiculoId,
      'driver_id': motoristaId,
      'type': tipo.name,
      'problems': problemas,
      'timestamp': dataHora.toIso8601String(),
      'is_completed': concluida,
    };
  }

  Vistoria copiarCom({
    String? id,
    String? percursoId,
    String? veiculoId,
    String? motoristaId,
    TipoVistoria? tipo,
    String? problemas,
    DateTime? dataHora,
    bool? concluida,
  }) {
    return Vistoria(
      id: id ?? this.id,
      percursoId: percursoId ?? this.percursoId,
      veiculoId: veiculoId ?? this.veiculoId,
      motoristaId: motoristaId ?? this.motoristaId,
      tipo: tipo ?? this.tipo,
      problemas: problemas ?? this.problemas,
      dataHora: dataHora ?? this.dataHora,
      concluida: concluida ?? this.concluida,
    );
  }
}
