class FuelRefill {
  final String id;
  final String journeyId;
  final String vehicleId;
  final String driverId;
  final String gasStation;
  final double liters;
  final double? totalCost;
  final int odometerReading;
  final DateTime timestamp;

  FuelRefill({
    required this.id,
    required this.journeyId,
    required this.vehicleId,
    required this.driverId,
    required this.gasStation,
    required this.liters,
    this.totalCost,
    required this.odometerReading,
    required this.timestamp,
  });

  factory FuelRefill.fromJson(Map<String, dynamic> json) {
    return FuelRefill(
      id: json['id'],
      journeyId: json['journey_id'],
      vehicleId: json['vehicle_id'],
      driverId: json['driver_id'],
      gasStation: json['gas_station'],
      liters: json['liters'],
      totalCost: json['total_cost'],
      odometerReading: json['odometer_reading'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'journey_id': journeyId,
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'gas_station': gasStation,
      'liters': liters,
      'total_cost': totalCost,
      'odometer_reading': odometerReading,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
