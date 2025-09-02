class InspectionStatus {
  final bool departureInspectionCompleted;
  final bool arrivalInspectionCompleted;

  InspectionStatus({
    this.departureInspectionCompleted = false,
    this.arrivalInspectionCompleted = false,
  });

  InspectionStatus copyWith({
    bool? departureInspectionCompleted,
    bool? arrivalInspectionCompleted,
  }) {
    return InspectionStatus(
      departureInspectionCompleted: departureInspectionCompleted ?? this.departureInspectionCompleted,
      arrivalInspectionCompleted: arrivalInspectionCompleted ?? this.arrivalInspectionCompleted,
    );
  }
}
