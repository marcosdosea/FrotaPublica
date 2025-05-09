class VeiculoPecaInsumo {
  final int id;
  final int veiculoId;
  final int pecaInsumoId;
  final String? descricaoPecaInsumo;
  final int quantidade;

  VeiculoPecaInsumo({
    required this.id,
    required this.veiculoId,
    required this.pecaInsumoId,
    this.descricaoPecaInsumo,
    required this.quantidade,
  });

  factory VeiculoPecaInsumo.deJson(Map<String, dynamic> json) {
    return VeiculoPecaInsumo(
      id: json['id'],
      veiculoId: json['veiculoId'],
      pecaInsumoId: json['pecaInsumoId'],
      descricaoPecaInsumo: json['descricaoPecaInsumo'],
      quantidade: json['quantidade'],
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'veiculoId': veiculoId,
      'pecaInsumoId': pecaInsumoId,
      'descricaoPecaInsumo': descricaoPecaInsumo,
      'quantidade': quantidade,
    };
  }
}
