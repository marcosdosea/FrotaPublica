class MarcaPecaInsumo {
  final int id;
  final String nome;

  MarcaPecaInsumo({
    required this.id,
    required this.nome,
  });

  factory MarcaPecaInsumo.deJson(Map<String, dynamic> json) {
    return MarcaPecaInsumo(
      id: json['id'],
      nome: json['nome'],
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'nome': nome,
    };
  }
}
