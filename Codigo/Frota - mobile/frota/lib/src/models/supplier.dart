class Supplier {
  final String id;
  final String name;
  final String? cnpj;
  final String? address;
  final String? phone;
  final String? email;

  Supplier({
    required this.id,
    required this.name,
    this.cnpj,
    this.address,
    this.phone,
    this.email,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id']?.toString() ?? '',
      name: json['nome'] ?? json['razaoSocial'] ?? '',
      cnpj: json['cnpj'],
      address: json['endereco'],
      phone: json['telefone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': name,
      'cnpj': cnpj,
      'endereco': address,
      'telefone': phone,
      'email': email,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Supplier && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
