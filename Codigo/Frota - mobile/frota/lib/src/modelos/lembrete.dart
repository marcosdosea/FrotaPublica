class Lembrete {
  final int id;
  final int veiculoId;
  final String titulo;
  final String? descricao;
  final DateTime dataCriacao;
  final bool concluido;

  Lembrete({
    required this.id,
    required this.veiculoId,
    required this.titulo,
    this.descricao,
    required this.dataCriacao,
    required this.concluido,
  });

  factory Lembrete.deJson(Map<String, dynamic> json) {
    return Lembrete(
      id: json['id'],
      veiculoId: json['veiculoId'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      dataCriacao: DateTime.parse(json['dataCriacao']),
      concluido: json['concluido'],
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'veiculoId': veiculoId,
      'titulo': titulo,
      'descricao': descricao,
      'dataCriacao': dataCriacao.toIso8601String(),
      'concluido': concluido,
    };
  }

  Lembrete copiarCom({
    int? id,
    int? veiculoId,
    String? titulo,
    String? descricao,
    DateTime? dataCriacao,
    bool? concluido,
  }) {
    return Lembrete(
      id: id ?? this.id,
      veiculoId: veiculoId ?? this.veiculoId,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      concluido: concluido ?? this.concluido,
    );
  }
}
