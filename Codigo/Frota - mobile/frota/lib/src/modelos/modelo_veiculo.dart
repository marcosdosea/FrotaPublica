class ModeloVeiculo {
  final int id;
  final String descricao;
  final int? marcaVeiculoId;
  final String? nomeMarca;

  ModeloVeiculo({
    required this.id,
    required this.descricao,
    this.marcaVeiculoId,
    this.nomeMarca,
  });

  factory ModeloVeiculo.deJson(Map<String, dynamic> json) {
    return ModeloVeiculo(
      id: json['id'],
      descricao: json['descricao'],
      marcaVeiculoId: json['marcaVeiculoId'],
      nomeMarca: json['nomeMarca'],
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'descricao': descricao,
      'marcaVeiculoId': marcaVeiculoId,
      'nomeMarca': nomeMarca,
    };
  }
}
