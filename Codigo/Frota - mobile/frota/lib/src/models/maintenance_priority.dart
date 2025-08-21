enum MaintenancePriority {
  baixa('B', 'Baixa'),
  media('M', 'Média'),
  alta('A', 'Alta'),
  urgente('U', 'Urgente');

  const MaintenancePriority(this.code, this.label);

  final String code;
  final String label;

  static MaintenancePriority fromCode(String code) {
    return MaintenancePriority.values.firstWhere(
      (priority) => priority.code == code,
      orElse: () => MaintenancePriority.media,
    );
  }

  static MaintenancePriority fromLabel(String label) {
    return MaintenancePriority.values.firstWhere(
      (priority) => priority.label == label,
      orElse: () => MaintenancePriority.media,
    );
  }
}
