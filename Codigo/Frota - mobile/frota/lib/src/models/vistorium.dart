import 'package:intl/intl.dart';

enum TipoVistoria {
  saida,
  chegada
}

class Vistorium {
  final int id;
  final int percursoId;
  final int veiculoId;
  final String? placaVeiculo;
  final int pessoaId;
  final String? nomeMotorista;
  final String tipo;
  final String? problemas;
  final DateTime dataHora;
  final bool concluida;

  Vistorium({
    required this.id,
    required this.percursoId,
    required this.veiculoId,
    this.placaVeiculo,
    required this.pessoaId,
    this.nomeMotorista,
    required this.tipo,
    this.problemas,
    required this.dataHora,
    required this.concluida,
  });

  factory Vistorium.fromJson(Map<String, dynamic> json) {
    return Vistorium(
      id: json['id'],
      percursoId: json['percursoId'],
      veiculoId: json['veiculoId'],
      placaVeiculo: json['placaVeiculo'],
      pessoaId: json['pessoaId'],
      nomeMotorista: json['nomeMotorista'],
      tipo: json['tipo'],
      problemas: json['problemas'],
      dataHora: DateTime.parse(json['dataHora']),
      concluida: json['concluida'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'percursoId': percursoId,
      'veiculoId': veiculoId,
      'placaVeiculo': placaVeiculo,
      'pessoaId': pessoaId,
      'nomeMotorista': nomeMotorista,
      'tipo': tipo,
      'problemas': problemas,
      'dataHora': dataHora.toIso8601String(),
      'concluida': concluida,
    };
  }

  TipoVistoria get tipoVistoria {
    return tipo.toLowerCase() == 'saida' ? TipoVistoria.saida : TipoVistoria.chegada;
  }
}
