class ManutencaoPecaInsumo {
  final int id;
  final int manutencaoId;
  final int pecaInsumoId;
  final String? descricaoPecaInsumo;
  final int quantidade;

  ManutencaoPecaInsumo({
    required this.id,
    required this.manutencaoId,
    required this.pecaInsumoId,
    this.descricaoPecaInsumo,
    required this.quantidade,
  });

  factory ManutencaoPecaInsumo.deJson(Map<String, dynamic> json) {
    return ManutencaoPecaInsumo(
      id: json['id'],
      manutencaoId: json['manutencaoId'],
      pecaInsumoId: json['pecaInsumoId'],
      descricaoPecaInsumo: json['descricaoPecaInsumo'],
      quantidade: json['quantidade'],
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'manutencaoId': manutencaoId,
      'pecaInsumoId': pecaInsumoId,
      'descricaoPecaInsumo': descricaoPecaInsumo,
      'quantidade': quantidade,
    };
  }
}
