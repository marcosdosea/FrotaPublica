import 'package:intl/intl.dart';

class Percurso {
  final int id;
  final int veiculoId;
  final String? placaVeiculo;
  final String? modeloVeiculo;
  final int pessoaId;
  final String? nomeMotorista;
  final String origem;
  final String destino;
  final int hodometroInicial;
  final int? hodometroFinal;
  final DateTime dataHoraSaida;
  final DateTime? dataHoraChegada;
  final bool ativo;
  final double? distanciaPercorrida;
  final List<int>? abastecimentoIds;

  Percurso({
    required this.id,
    required this.veiculoId,
    this.placaVeiculo,
    this.modeloVeiculo,
    required this.pessoaId,
    this.nomeMotorista,
    required this.origem,
    required this.destino,
    required this.hodometroInicial,
    this.hodometroFinal,
    required this.dataHoraSaida,
    this.dataHoraChegada,
    required this.ativo,
    this.distanciaPercorrida,
    this.abastecimentoIds,
  });

  factory Percurso.deJson(Map<String, dynamic> json) {
    return Percurso(
      id: json['id'],
      veiculoId: json['veiculoId'],
      placaVeiculo: json['placaVeiculo'],
      modeloVeiculo: json['modeloVeiculo'],
      pessoaId: json['pessoaId'],
      nomeMotorista: json['nomeMotorista'],
      origem: json['origem'],
      destino: json['destino'],
      hodometroInicial: json['hodometroInicial'],
      hodometroFinal: json['hodometroFinal'],
      dataHoraSaida: DateTime.parse(json['dataHoraSaida']),
      dataHoraChegada: json['dataHoraChegada'] != null
          ? DateTime.parse(json['dataHoraChegada'])
          : null,
      ativo: json['ativo'],
      distanciaPercorrida: json['distanciaPercorrida'],
      abastecimentoIds: json['abastecimentoIds'] != null
          ? List<int>.from(json['abastecimentoIds'])
          : null,
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'veiculoId': veiculoId,
      'placaVeiculo': placaVeiculo,
      'modeloVeiculo': modeloVeiculo,
      'pessoaId': pessoaId,
      'nomeMotorista': nomeMotorista,
      'origem': origem,
      'destino': destino,
      'hodometroInicial': hodometroInicial,
      'hodometroFinal': hodometroFinal,
      'dataHoraSaida': dataHoraSaida.toIso8601String(),
      'dataHoraChegada': dataHoraChegada?.toIso8601String(),
      'ativo': ativo,
      'distanciaPercorrida': distanciaPercorrida,
      'abastecimentoIds': abastecimentoIds,
    };
  }

  String get dataHoraSaidaFormatada {
    return DateFormat('dd/MM/yyyy HH:mm').format(dataHoraSaida);
  }

  // Cálculo de progresso do percurso (para UI)
  double get progresso {
    if (!ativo || dataHoraChegada != null) return 1.0;
    
    // Estimativa baseada no tempo (simplificada)
    final agora = DateTime.now();
    final duracaoEstimadaTotal = const Duration(hours: 2); // Estimativa fixa para exemplo
    final duracaoDecorrida = agora.difference(dataHoraSaida);
    
    return (duracaoDecorrida.inMinutes / duracaoEstimadaTotal.inMinutes).clamp(0.0, 1.0);
  }

  // Duração do percurso
  String get duracao {
    if (!ativo) return '0:00 h';
    
    final fim = dataHoraChegada ?? DateTime.now();
    final diferenca = fim.difference(dataHoraSaida);
    
    final horas = diferenca.inHours;
    final minutos = diferenca.inMinutes.remainder(60);
    
    return '$horas:${minutos.toString().padLeft(2, '0')} h';
  }
}
