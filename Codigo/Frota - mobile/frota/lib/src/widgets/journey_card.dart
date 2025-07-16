import 'package:flutter/material.dart';
import '../models/journey.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';

String formatDurationAbbr(Duration duration) {
  final days = duration.inDays;
  final hours = duration.inHours % 24;
  final minutes = duration.inMinutes % 60;
  final parts = <String>[];
  if (days > 0) parts.add('${days}d');
  if (hours > 0) parts.add('${hours}h');
  if (minutes > 0) parts.add('${minutes}m');
  if (parts.isEmpty) return '0m';
  return parts.join(' ');
}

class JourneyCard extends StatelessWidget {
  final Journey journey;
  final VoidCallback? onTap;

  const JourneyCard({
    super.key,
    required this.journey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Partida',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      Text(
                        journey.origin,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0066CC),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Destino',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      Text(
                        journey.destination,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF3A3A5C)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: journey.progress,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066CC),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: -4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0066CC),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: -4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: journey.isActive
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF3A3A5C)
                                : Colors.grey[300])
                            : const Color(0xFF0066CC),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<VehicleProvider>(
                    builder: (context, vehicleProvider, child) {
                      final currentVehicle = vehicleProvider.currentVehicle;
                      final odometerAtual = journey.finalOdometer ??
                          currentVehicle?.odometer ??
                          0;
                      final now = DateTime.now();
                      final start = journey.departureTime;
                      final end = journey.arrivalTime ?? now;
                      final duration = end.difference(start);
                      final durationStr = formatDurationAbbr(duration);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Odômetro atual: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                              ),
                              Text(
                                '$odometerAtual km',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Duração: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                              ),
                              Text(
                                durationStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
