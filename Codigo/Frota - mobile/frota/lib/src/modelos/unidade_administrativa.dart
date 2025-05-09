class UnidadeAdministrativa {
  final int id;
  final String nome;
  final String? sigla;
  final int? unidadeSuperiorId;
  final String? nomeSuperior;

  UnidadeAdministrativa({
    required this.id,
    required this.nome,
    this.sigla,
    this.unidadeSuperiorId,
    this.nomeSuperior,
  });

  factory UnidadeAdministrativa.deJson(Map<String, dynamic> json) {
    return UnidadeAdministrativa(
      id: json['id'],
      nome: json['nome'],
      sigla: json['sigla'],
      unidadeSuperiorId: json['unidadeSuperiorId'],
      nomeSuperior: json['nomeSuperior'],
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'nome': nome,
      'sigla': sigla,
      'unidadeSuperiorId': unidadeSuperiorId,
      'nomeSuperior': nomeSuperior,
    };
  }
}
