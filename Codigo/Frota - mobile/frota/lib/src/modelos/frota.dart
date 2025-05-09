class Frota {
  final int id;
  final String descricao;
  final int? unidadeAdministrativaId;
  final String? nomeUnidade;

  Frota({
    required this.id,
    required this.descricao,
    this.unidadeAdministrativaId,
    this.nomeUnidade,
  });

  factory Frota.deJson(Map<String, dynamic> json) {
    return Frota(
      id: json['id'],
      descricao: json['descricao'],
      unidadeAdministrativaId: json['unidadeAdministrativaId'],
      nomeUnidade: json['nomeUnidade'],
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'descricao': descricao,
      'unidadeAdministrativaId': unidadeAdministrativaId,
      'nomeUnidade': nomeUnidade,
    };
  }
}
