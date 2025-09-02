class Fornecedor {
  final int id;
  final String nome;
  final String? cnpj;
  final String? telefone;
  final String? email;
  final String? endereco;
  final bool ativo;

  Fornecedor({
    required this.id,
    required this.nome,
    this.cnpj,
    this.telefone,
    this.email,
    this.endereco,
    required this.ativo,
  });

  factory Fornecedor.deJson(Map<String, dynamic> json) {
    return Fornecedor(
      id: json['id'],
      nome: json['nome'],
      cnpj: json['cnpj'],
      telefone: json['telefone'],
      email: json['email'],
      endereco: json['endereco'],
      ativo: json['ativo'],
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'nome': nome,
      'cnpj': cnpj,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'ativo': ativo,
    };
  }
}
