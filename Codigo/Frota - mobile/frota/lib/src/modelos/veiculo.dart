class Veiculo {
  final String id;
  final String modelo;
  final String placa;
  final int hodometro;
  final String? urlImagem;
  final bool disponivel;
  final String? motoristaAtualId;
  final List<String>? problemasManutencao;
  final double? combustivelGasto;
  final int? distanciaPercorrida;
  final double? eficienciaCombustivel;

  Veiculo({
    required this.id,
    required this.modelo,
    required this.placa,
    required this.hodometro,
    this.urlImagem,
    required this.disponivel,
    this.motoristaAtualId,
    this.problemasManutencao,
    this.combustivelGasto,
    this.distanciaPercorrida,
    this.eficienciaCombustivel,
  });

  factory Veiculo.deJson(Map<String, dynamic> json) {
    return Veiculo(
      id: json['id'],
      modelo: json['model'],
      placa: json['license_plate'],
      hodometro: json['odometer'],
      urlImagem: json['image_url'],
      disponivel: json['is_available'],
      motoristaAtualId: json['current_driver_id'],
      problemasManutencao: json['maintenance_issues'] != null
          ? List<String>.from(json['maintenance_issues'])
          : null,
      combustivelGasto: json['fuel_spent'],
      distanciaPercorrida: json['distance_traveled'],
      eficienciaCombustivel: json['fuel_efficiency'],
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'model': modelo,
      'license_plate': placa,
      'odometer': hodometro,
      'image_url': urlImagem,
      'is_available': disponivel,
      'current_driver_id': motoristaAtualId,
      'maintenance_issues': problemasManutencao,
      'fuel_spent': combustivelGasto,
      'distance_traveled': distanciaPercorrida,
      'fuel_efficiency': eficienciaCombustivel,
    };
  }

  Veiculo copiarCom({
    String? id,
    String? modelo,
    String? placa,
    int? hodometro,
    String? urlImagem,
    bool? disponivel,
    String? motoristaAtualId,
    List<String>? problemasManutencao,
    double? combustivelGasto,
    int? distanciaPercorrida,
    double? eficienciaCombustivel,
  }) {
    return Veiculo(
      id: id ?? this.id,
      modelo: modelo ?? this.modelo,
      placa: placa ?? this.placa,
      hodometro: hodometro ?? this.hodometro,
      urlImagem: urlImagem ?? this.urlImagem,
      disponivel: disponivel ?? this.disponivel,
      motoristaAtualId: motoristaAtualId ?? this.motoristaAtualId,
      problemasManutencao: problemasManutencao ?? this.problemasManutencao,
      combustivelGasto: combustivelGasto ?? this.combustivelGasto,
      distanciaPercorrida: distanciaPercorrida ?? this.distanciaPercorrida,
      eficienciaCombustivel: eficienciaCombustivel ?? this.eficienciaCombustivel,
    );
  }
}
