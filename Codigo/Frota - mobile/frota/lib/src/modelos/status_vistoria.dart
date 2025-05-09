class StatusVistoria {
  final bool vistoriaSaidaConcluida;
  final bool vistoriaChegadaConcluida;

  StatusVistoria({
    this.vistoriaSaidaConcluida = false,
    this.vistoriaChegadaConcluida = false,
  });

  StatusVistoria copiarCom({
    bool? vistoriaSaidaConcluida,
    bool? vistoriaChegadaConcluida,
  }) {
    return StatusVistoria(
      vistoriaSaidaConcluida: vistoriaSaidaConcluida ?? this.vistoriaSaidaConcluida,
      vistoriaChegadaConcluida: vistoriaChegadaConcluida ?? this.vistoriaChegadaConcluida,
    );
  }
}
