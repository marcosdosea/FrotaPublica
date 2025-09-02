import 'package:intl/intl.dart';

enum StatusManutencao {
  pendente,
  emAndamento,
  concluida,
  rejeitada
}

class Manutencao {
  final int id;
  final int veiculoId;
  final String? placaVeiculo;
  final String? modeloVeiculo;
  final int pessoaId;
  final String? nomeSolicitante;
  final String descricao;
  final DateTime dataHora;
  final String status;
  final String? observacoesTecnicas;
  final DateTime? dataConclusao;

  Manutencao({
    required this.id,
    required this.veiculoId,
    this.placaVeiculo,
    this.modeloVeiculo,
    required this.pessoaId,
    this.nomeSolicitante,
    required this.descricao,
    required this.dataHora,
    required this.status,
    this.observacoesTecnicas,
    this.dataConclusao,
  });

  factory Manutencao.fromJson(Map<String, dynamic> json) {
    return Manutencao(
      id: json['id'],
      veiculoId: json['veiculoId'],
      placaVeiculo: json['placaVeiculo'],
      modeloVeiculo: json['modeloVeiculo'],
      pessoaId: json['pessoaId'],
      nomeSolicitante: json['nomeSolicitante'],
      descricao: json['descricao'],
      dataHora: DateTime.parse(json['dataHora']),
      status: json['status'],
      observacoesTecnicas: json['observacoesTecnicas'],
      dataConclusao: json['dataConclusao'] != null
          ? DateTime.parse(json['dataConclusao'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'veiculoId': veiculoId,
      'placaVeiculo': placaVeiculo,
      'modeloVeiculo': modeloVeiculo,
      'pessoaId': pessoaId,
      'nomeSolicitante': nomeSolicitante,
      'descricao': descricao,
      'dataHora': dataHora.toIso8601String(),
      'status': status,
      'observacoesTecnicas': observacoesTecnicas,
      'dataConclusao': dataConclusao?.toIso8601String(),
    };
  }

  StatusManutencao get statusManutencao {
    switch (status.toLowerCase()) {
      case 'pendente':
        return StatusManutencao.pendente;
      case 'emandamento':
        return StatusManutencao.emAndamento;
      case 'concluida':
        return StatusManutencao.concluida;
      case 'rejeitada':
        return StatusManutencao.rejeitada;
      default:
        return StatusManutencao.pendente;
    }
  }
}
