import 'package:flutter/material.dart';
import '../models/journey.dart';
import '../models/vehicle.dart';

class VehicleJourneySlider extends StatefulWidget {
  final Vehicle vehicle;
  final Journey? journey;
  final double totalLiters;
  final VoidCallback? onMapTap;

  const VehicleJourneySlider({
    super.key,
    required this.vehicle,
    this.journey,
    required this.totalLiters,
    this.onMapTap,
  });

  @override
  State<VehicleJourneySlider> createState() => _VehicleJourneySliderState();
}

class _VehicleJourneySliderState extends State<VehicleJourneySlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160, // Altura fixa para o card
      child: Column(
        children: [
          // PageView com os dois cards
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildVehicleCard(),
                _buildJourneyCard(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPageIndicator(0),
              const SizedBox(width: 8),
              _buildPageIndicator(1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard() {
    // Calcular duração do percurso
    final journey = widget.journey;
    String duration = 'N/A';

    if (journey != null && journey.departureTime != null) {
      final now = DateTime.now();
      final start = journey.departureTime!;
      final durationObj = now.difference(start);

      final hours = durationObj.inHours;
      final minutes = durationObj.inMinutes % 60;

      if (hours > 0) {
        duration = '${hours}h ${minutes}m';
      } else {
        duration = '${minutes}m';
      }
    }

    // Calcular km percorridos
    final odometerDifference = journey != null
        ? (widget.vehicle.odometer ?? 0) - (journey.initialOdometer ?? 0)
        : 0;

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.vehicle.model,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Placa: ',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      widget.vehicle.licensePlate,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066CC).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.timer,
                        color: Color(0xFF0066CC),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      duration,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF0066CC),
                      ),
                    ),
                    Text(
                      'Duração',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 80,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF3A3A5C)
                      : Colors.grey[300],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066CC).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.straighten,
                        color: Color(0xFF0066CC),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$odometerDifference',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF0066CC),
                      ),
                    ),
                    Text(
                      'Km percorridos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyCard() {
    final journey = widget.journey;

    if (journey == null) {
      return Card(
        color: Theme.of(context).cardColor,
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              'Nenhum percurso ativo no momento',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0066CC),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFF0066CC).withOpacity(0.2),
                borderRadius: BorderRadius.circular(1),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066CC),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Informações de odômetro atual e litros abastecidos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Odômetro Atual',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    Text(
                      '${widget.vehicle.odometer ?? 0} km',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Saída: ${journey.departureTime != null ? "${journey.departureTime!.day.toString().padLeft(2, '0')}/${journey.departureTime!.month.toString().padLeft(2, '0')}/${journey.departureTime!.year} ${journey.departureTime!.hour.toString().padLeft(2, '0')}:${journey.departureTime!.minute.toString().padLeft(2, '0')}" : "N/A"}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0066CC),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (widget.onMapTap != null)
                  ElevatedButton(
                    onPressed: widget.onMapTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066CC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Ver Mapa',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index
            ? const Color(0xFF0066CC)
            : const Color(0xFF0066CC).withOpacity(0.3),
      ),
    );
  }
}
