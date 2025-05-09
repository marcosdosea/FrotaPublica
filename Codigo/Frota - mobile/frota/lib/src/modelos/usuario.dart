class Usuario {
  final String id;
  final String nomeUsuario;
  final String? email;
  final String? telefone;
  final int? pessoaId;
  final String? nomePessoa;
  final List<String>? papeis;

  Usuario({
    required this.id,
    required this.nomeUsuario,
    this.email,
    this.telefone,
    this.pessoaId,
    this.nomePessoa,
    this.papeis,
  });

  factory Usuario.deJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nomeUsuario: json['userName'],
      email: json['email'],
      telefone: json['phoneNumber'],
      pessoaId: json['pessoaId'],
      nomePessoa: json['nomePessoa'],
      papeis: json['roles'] != null ? List<String>.from(json['roles']) : null,
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'userName': nomeUsuario,
      'email': email,
      'phoneNumber': telefone,
      'pessoaId': pessoaId,
      'nomePessoa': nomePessoa,
      'roles': papeis,
    };
  }

  bool get ehAdmin {
    return papeis?.contains('Admin') ?? false;
  }

  bool get ehMotorista {
    return papeis?.contains('Motorista') ?? false;
  }
}
