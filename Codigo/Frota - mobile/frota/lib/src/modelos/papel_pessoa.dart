class PapelPessoa {
  final int id;
  final String descricao;

  PapelPessoa({
    required this.id,
    required this.descricao,
  });

  factory PapelPessoa.deJson(Map<String, dynamic> json) {
    return PapelPessoa(
      id: json['id'],
      descricao: json['descricao'],
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'descricao': descricao,
    };
  }
}
