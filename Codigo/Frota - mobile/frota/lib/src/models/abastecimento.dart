import 'package:intl/intl.dart';

class Abastecimento {
  final int id;
  final int percursoId;
  final int veiculoId;
  final String? placaVeiculo;
  final int pessoaId;
  final String? nomeMotorista;
  final String posto;
  final double litros;
  final double? valorTotal;
  final int hodometro;
  final DateTime dataHora;

  Abastecimento({
    required this.id,
    required this.percursoId,
    required this.veiculoId,
    this.placaVeiculo,
    required this.pessoaId,
    this.nomeMotorista,
    required this.posto,
    required this.litros,
    this.valorTotal,
    required this.hodometro,
    required this.dataHora,
  });

  factory Abastecimento.fromJson(Map<String, dynamic> json) {
    return Abastecimento(
      id: json['id'],
      percursoId: json['percursoId'],
      veiculoId: json['veiculoId'],
      placaVeiculo: json['placaVeiculo'],
      pessoaId: json['pessoaId'],
      nomeMotorista: json['nomeMotorista'],
      posto: json['posto'],
      litros: json['litros'],
      valorTotal: json['valorTotal'],
      hodometro: json['hodometro'],
      dataHora: DateTime.parse(json['dataHora']),
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
      'posto': posto,
      'litros': litros,
      'valorTotal': valorTotal,
      'hodometro': hodometro,
      'dataHora': dataHora.toIso8601String(),
    };
  }

  String get formattedValorTotal {
    if (valorTotal == null) return 'R\$ 0,00';
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(valorTotal);
  }
}
