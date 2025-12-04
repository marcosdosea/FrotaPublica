class Reminder {
  final String id;
  final String vehicleId;
  final String title;
  final String? description;
  final DateTime createdAt;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.vehicleId,
    required this.title,
    this.description,
    required this.createdAt,
    required this.isCompleted,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      isCompleted: json['is_completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'is_completed': isCompleted,
    };
  }

  Reminder copyWith({
    String? id,
    String? vehicleId,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return Reminder(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
