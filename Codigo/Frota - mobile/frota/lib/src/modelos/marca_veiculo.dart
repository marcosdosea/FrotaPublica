class MarcaVeiculo {
  final int id;
  final String nome;

  MarcaVeiculo({
    required this.id,
    required this.nome,
  });

  factory MarcaVeiculo.deJson(Map<String, dynamic> json) {
    return MarcaVeiculo(
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
