class User {
  final String id;
  final String name;
  final String email;
  final String? cpf;
  final String? photoUrl;
  final String role; // 'driver', 'admin', etc.
  final int?
      unidadeAdministrativaId; // ID da unidade administrativa do motorista

  User({
    required this.id,
    required this.name,
    required this.email,
    this.cpf,
    this.photoUrl,
    required this.role,
    this.unidadeAdministrativaId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['userId'] ?? '',
      name: json['name'] ?? json['nomeCompleto'] ?? '',
      email: json['email'] ?? '',
      cpf: json['cpf'] ?? json['cpfCnpj'] ?? '',
      photoUrl: json['photo_url'] ?? json['fotoUrl'] ?? '',
      role: json['role'] ?? json['perfil'] ?? 'driver',
      unidadeAdministrativaId: json['unidadeAdministrativaId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'cpf': cpf,
      'photo_url': photoUrl,
      'role': role,
      'unidadeAdministrativaId': unidadeAdministrativaId,
    };
  }

  // Mock user para desenvolvimento
  static User mockDriver() {
    return User(
      id: '1',
      name: 'João Motorista',
      email: 'joao@example.com',
      cpf: '123.456.789-00',
      role: 'driver',
      unidadeAdministrativaId: 1,
    );
  }
}
