import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/journey.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';
import '../providers/journey_provider.dart';
import '../providers/fuel_provider.dart';
import '../models/inspection_status.dart';
import '../services/inspection_service.dart';
import 'fuel_registration_screen.dart';
import 'inspection_selection_screen.dart';
import 'maintenance_request_screen.dart';
import '../utils/formatters.dart';

class MapScreen extends StatefulWidget {
  final Journey journey;

  const MapScreen({
    super.key,
    required this.journey,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  InspectionStatus inspectionStatus = InspectionStatus();
  final InspectionService _inspectionService = InspectionService();

  @override
  void initState() {
    super.initState();
    _setupMapData();
    _checkInspectionStatus();
  }

  void _setupMapData() {
    _markers.clear();
    _polylines.clear();

    // Verificar se temos coordenadas válidas
    if (widget.journey.departureLatitude != null &&
        widget.journey.departureLongitude != null &&
        widget.journey.arrivalLatitude != null &&
        widget.journey.arrivalLongitude != null) {

      final departureLatLng = LatLng(
        widget.journey.departureLatitude!,
        widget.journey.departureLongitude!,
      );

      final arrivalLatLng = LatLng(
        widget.journey.arrivalLatitude!,
        widget.journey.arrivalLongitude!,
      );

      // Adicionar marcadores
      _markers.add(
        Marker(
          markerId: const MarkerId('departure'),
          position: departureLatLng,
          infoWindow: InfoWindow(
            title: 'Partida',
            snippet: widget.journey.departureLocation ?? 'Local de partida',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('arrival'),
          position: arrivalLatLng,
          infoWindow: InfoWindow(
            title: 'Destino',
            snippet: widget.journey.arrivalLocation ?? 'Local de chegada',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // Adicionar linha da rota
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [departureLatLng, arrivalLatLng],
          color: const Color(0xFF116AD5),
          width: 4,
        ),
      );
    }
  }

  Future<void> _checkInspectionStatus() async {
    try {
      final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
      final currentVehicle = vehicleProvider.currentVehicle;

      if (currentVehicle != null) {
        // Verificar vistoria de saída
        bool departureCompleted =
        await _inspectionService.hasInspectionBeenCompleted(
          currentVehicle.id,
          'S',
        );

        // Verificar vistoria de retorno
        bool arrivalCompleted =
        await _inspectionService.hasInspectionBeenCompleted(
          currentVehicle.id,
          'R',
        );

        if (mounted) {
          setState(() {
            inspectionStatus = InspectionStatus(
              departureInspectionCompleted: departureCompleted,
              arrivalInspectionCompleted: arrivalCompleted,
            );
          });
        }
      }
    } catch (e) {
      print('Erro ao verificar status das vistorias: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Configurar barra de status
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF116AD5),
      statusBarIconBrightness: Brightness.light,
    ));

    // Determinar posição inicial do mapa
    LatLng initialPosition;
    double initialZoom = 10.0;

    if (widget.journey.departureLatitude != null &&
        widget.journey.departureLongitude != null) {
      initialPosition = LatLng(
        widget.journey.departureLatitude!,
        widget.journey.departureLongitude!,
      );
      initialZoom = 12.0;
    } else {
      // Fallback para Sergipe
      initialPosition = const LatLng(-10.9472, -37.0731);
      initialZoom = 8.0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF116AD5),
      body: Column(
        children: [
          // Barra de status
          Container(
            height: MediaQuery.of(context).padding.top,
            color: const Color(0xFF116AD5),
          ),
          // Header
          Container(
            color: const Color(0xFF116AD5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Percurso',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Para balancear o botão de voltar
              ],
            ),
          ),
          // Conteúdo
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card do mapa
                    Card(
                      color: Theme.of(context).cardColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Header do card com partida e destino
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
                                      widget.journey.departureLocation ?? 'Não informado',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF116AD5),
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
                                      widget.journey.arrivalLocation ?? 'Não informado',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF116AD5),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Mapa
                            Container(
                              height: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xFF3A3A5C)
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: initialPosition,
                                    zoom: initialZoom,
                                  ),
                                  markers: _markers,
                                  polylines: _polylines,
                                  onMapCreated: (GoogleMapController controller) {
                                    _mapController = controller;

                                    // Se temos marcadores, ajustar a câmera para mostrar todos
                                    if (_markers.isNotEmpty) {
                                      _fitMarkersInView();
                                    }
                                  },
                                  zoomControlsEnabled: true,
                                  mapToolbarEnabled: false,
                                  myLocationButtonEnabled: false,
                                  compassEnabled: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Informações do percurso
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Odômetros',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF116AD5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Inicial: ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    Text(
                                      '${widget.journey.initialOdometer ?? 0}km',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Consumer<VehicleProvider>(
                                  builder: (context, vehicleProvider, child) {
                                    final currentVehicle = vehicleProvider.currentVehicle;
                                    return Row(
                                      children: [
                                        Text(
                                          'Final: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        Text(
                                          '${currentVehicle?.odometer ?? 0}km',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                if (widget.journey.departureTime != null)
                                  Row(
                                    children: [
                                      Text(
                                        'Saída: ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF116AD5),
                                        ),
                                      ),
                                      Text(
                                        Formatters.formatDateTime(widget.journey.departureTime!),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF116AD5),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Seção de registros
                    Text(
                      'Registros',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Cards de registros
                    Consumer<VehicleProvider>(
                      builder: (context, vehicleProvider, child) {
                        final currentVehicle = vehicleProvider.currentVehicle;

                        return Row(
                          children: [
                            Expanded(
                              child: _buildRegistrationCard(
                                icon: Icons.local_gas_station,
                                title: 'Registrar\nAbastecimento',
                                onTap: currentVehicle != null ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FuelRegistrationScreen(
                                        vehicleId: currentVehicle.id,
                                      ),
                                    ),
                                  );
                                } : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildRegistrationCard(
                                icon: Icons.checklist,
                                title: 'Realizar\nVistoria',
                                hasNotification: !inspectionStatus.departureInspectionCompleted ||
                                    !inspectionStatus.arrivalInspectionCompleted,
                                isCompleted: inspectionStatus.departureInspectionCompleted &&
                                    inspectionStatus.arrivalInspectionCompleted,
                                onTap: currentVehicle != null ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InspectionSelectionScreen(
                                        vehicleId: currentVehicle.id,
                                      ),
                                    ),
                                  ).then((value) {
                                    _checkInspectionStatus();
                                  });
                                } : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildRegistrationCard(
                                icon: Icons.exit_to_app,
                                title: 'Registrar\nSaída',
                                onTap: currentVehicle != null ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MaintenanceRequestScreen(
                                        vehicleId: currentVehicle.id,
                                      ),
                                    ),
                                  );
                                } : null,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationCard({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
    bool hasNotification = false,
    bool isCompleted = false,
  }) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066CC).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFF0066CC),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (hasNotification)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (isCompleted)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0066CC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _fitMarkersInView() {
    if (_markers.length < 2 || _mapController == null) return;

    final bounds = _calculateBounds();
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }

  LatLngBounds _calculateBounds() {
    final lats = _markers.map((m) => m.position.latitude).toList();
    final lngs = _markers.map((m) => m.position.longitude).toList();

    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
