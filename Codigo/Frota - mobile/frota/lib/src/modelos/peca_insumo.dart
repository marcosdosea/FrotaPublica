class PecaInsumo {
  final int id;
  final String descricao;
  final int? marcaPecaInsumoId;
  final String? nomeMarca;

  PecaInsumo({
    required this.id,
    required this.descricao,
    this.marcaPecaInsumoId,
    this.nomeMarca,
  });

  factory PecaInsumo.deJson(Map<String, dynamic> json) {
    return PecaInsumo(
      id: json['id'],
      descricao: json['descricao'],
      marcaPecaInsumoId: json['marcaPecaInsumoId'],
      nomeMarca: json['nomeMarca'],
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'descricao': descricao,
      'marcaPecaInsumoId': marcaPecaInsumoId,
      'nomeMarca': nomeMarca,
    };
  }
}
