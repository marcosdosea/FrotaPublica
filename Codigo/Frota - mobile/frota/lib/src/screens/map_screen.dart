import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/journey.dart';
import '../providers/vehicle_provider.dart';
import '../models/inspection_status.dart';
import '../services/inspection_service.dart';
import 'fuel_registration_screen.dart';
import 'inspection_selection_screen.dart';
import 'maintenance_request_screen.dart';
import '../utils/formatters.dart';
import '../widgets/finish_journey_dialog.dart';
import '../providers/journey_provider.dart';
import '../providers/fuel_provider.dart';
import 'available_vehicles_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

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
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  InspectionStatus inspectionStatus = InspectionStatus();
  final InspectionService _inspectionService = InspectionService();
  bool _isLoadingRoute = false;
  String? _routeDistance;
  String? _routeDuration;

  // CHAVE DA API DO GOOGLE MAPS
  static const String _googleMapsApiKey =
      'AIzaSyCxFxCvXpzIcSL_ck0CQyk2Xc2YvOmiLlc';

  @override
  void initState() {
    super.initState();
    _setupMapData();
    _checkInspectionStatus();
  }

  void _setupMapData() async {
    // Limpar dados antigos
    _markers.clear();
    _polylines.clear();

    // Verificar se temos coordenadas válidas
    if (widget.journey.hasValidCoordinates) {
      print(
          '--- MAP_SCREEN: Coordenadas válidas encontradas. Origem: (${widget.journey.originLatitude}, ${widget.journey.originLongitude}), Destino: (${widget.journey.destinationLatitude}, ${widget.journey.destinationLongitude})');
      final departureLatLng = LatLng(
        widget.journey.originLatitude!,
        widget.journey.originLongitude!,
      );

      final arrivalLatLng = LatLng(
        widget.journey.destinationLatitude!,
        widget.journey.destinationLongitude!,
      );

      // Adicionar marcadores de partida e chegada
      _addMarkers(departureLatLng, arrivalLatLng);

      // Buscar e desenhar a rota
      await _getDirectionsRoute(departureLatLng, arrivalLatLng);
    } else {
      print(
          '--- MAP_SCREEN: Coordenadas inválidas ou ausentes. Exibindo mapa de Sergipe.');
    }

    // Atualizar a UI
    if (mounted) {
      setState(() {});
    }
  }

  void _addMarkers(LatLng origin, LatLng destination) {
    _markers.add(
      Marker(
        markerId: const MarkerId('departure'),
        position: origin,
        infoWindow: InfoWindow(
          title: 'Partida',
          snippet: widget.journey.origin,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('arrival'),
        position: destination,
        infoWindow: InfoWindow(
          title: 'Destino',
          snippet: widget.journey.destination,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  Future<void> _getDirectionsRoute(LatLng origin, LatLng destination) async {
    setState(() {
      _isLoadingRoute = true;
    });
    print(
        '--- MAP_SCREEN: _getDirectionsRoute chamado com Origem: $origin, Destino: $destination');

    try {
      final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${origin.latitude},${origin.longitude}&'
          'destination=${destination.latitude},${destination.longitude}&'
          'key=$_googleMapsApiKey&'
          'language=pt-BR';

      print('--- MAP_SCREEN: Chamando URL da API do Google Directions: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('--- MAP_SCREEN: Resposta da API recebida (StatusCode: 200).');
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && (data['routes'] as List).isNotEmpty) {
          print(
              '--- MAP_SCREEN: Status da rota é OK. Desenhando rota no mapa.');
          final route = data['routes'][0];
          final leg = route['legs'][0];

          // Extrair informações da rota
          _routeDistance = leg['distance']['text'];
          _routeDuration = leg['duration']['text'];

          // Decodificar os pontos da rota e criar a polyline
          final String encodedPolyline = route['overview_polyline']['points'];
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: _decodePolyline(encodedPolyline),
              color: const Color(0xFF116AD5),
              width: 5,
            ),
          );
        } else {
          print(
              '--- MAP_SCREEN: API retornou status: ${data['status']}. Desenhando linha reta como fallback.');
          // Fallback para linha reta se a API falhar
          _drawStraightLine(origin, destination);
        }
      } else {
        print(
            '--- MAP_SCREEN: Falha na chamada da API (StatusCode: ${response.statusCode}). Desenhando linha reta como fallback.');
        _drawStraightLine(origin, destination);
      }
    } catch (e) {
      print(
          '--- MAP_SCREEN: Erro na chamada da API: $e. Desenhando linha reta como fallback.');
      _drawStraightLine(origin, destination);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
        _fitMarkersInView();
      }
    }
  }

  void _drawStraightLine(LatLng origin, LatLng destination) {
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [origin, destination],
        color: const Color(0xFF116AD5),
        width: 5,
      ),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  Future<void> _checkInspectionStatus() async {
    try {
      final vehicleProvider =
      Provider.of<VehicleProvider>(context, listen: false);
      final currentVehicle = vehicleProvider.currentVehicle;

      if (currentVehicle != null) {
        bool departureCompleted = await _inspectionService
            .hasInspectionBeenCompleted(currentVehicle.id, 'S');
        bool arrivalCompleted = await _inspectionService
            .hasInspectionBeenCompleted(currentVehicle.id, 'R');

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
      // Tratar erro se necessário
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialPosition = const LatLng(-10.9472, -37.0731); // Sergipe
    double initialZoom = 8.0;

    if (widget.journey.hasValidCoordinates) {
      initialPosition = LatLng(
          widget.journey.originLatitude!, widget.journey.originLongitude!);
      initialZoom = 12.0;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Blue header with rounded bottom corners
          Container(
            padding:
            const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF116AD5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x29000000),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Percurso',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildMapCard(initialPosition, initialZoom),
                    ),
                    const SizedBox(height: 32),
                    _buildRegistrosSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard(LatLng initialPosition, double initialZoom) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildJourneyHeader(),
            const SizedBox(height: 16),
            _buildMapContainer(initialPosition, initialZoom),
            const SizedBox(height: 16),
            _buildOdometerInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLocationInfo('Partida', widget.journey.origin),
        _buildLocationInfo('Destino', widget.journey.destination,
            alignRight: true),
      ],
    );
  }

  Widget _buildLocationInfo(String label, String location,
      {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          location,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF116AD5),
          ),
          textAlign: alignRight ? TextAlign.end : TextAlign.start,
        ),
      ],
    );
  }

  Widget _buildMapContainer(LatLng initialPosition, double initialZoom) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: initialZoom,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _fitMarkersInView();
              },
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: true,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
              },
            ),
            if (_isLoadingRoute)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF116AD5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOdometerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Odômetros',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<VehicleProvider>(
          builder: (context, vehicleProvider, child) {
            final currentVehicle = vehicleProvider.currentVehicle;
            return Column(
              children: [
                _infoRow('Inicial:', '${widget.journey.initialOdometer}km'),
                const SizedBox(height: 4),
                _infoRow('Final:',
                    '${widget.journey.finalOdometer ?? currentVehicle?.odometer ?? '...'}km'),
                const SizedBox(height: 4),
                _infoRow('Hora de Saída:',
                    Formatters.formatDateTime(widget.journey.departureTime)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRegistrosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Registros',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Consumer<VehicleProvider>(
          builder: (context, vehicleProvider, child) {
            final currentVehicle = vehicleProvider.currentVehicle;

            return SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildActionCardHorizontal(
                    icon: Icons.local_gas_station,
                    title: 'Registrar\nAbastecimento',
                    onTap: () {
                      if (currentVehicle == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FuelRegistrationScreen(
                            vehicleId: currentVehicle.id,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionCardHorizontal(
                    icon: Icons.checklist,
                    title: 'Realizar Vistoria',
                    onTap: () {
                      if (currentVehicle == null) return;
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
                    },
                    hasNotification:
                    !inspectionStatus.departureInspectionCompleted ||
                        !inspectionStatus.arrivalInspectionCompleted,
                    isCompleted:
                    inspectionStatus.departureInspectionCompleted &&
                        inspectionStatus.arrivalInspectionCompleted,
                  ),
                  _buildActionCardHorizontal(
                    icon: Icons.build,
                    title: 'Solicitar Manutenção',
                    onTap: () {
                      if (currentVehicle == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MaintenanceRequestScreen(
                            vehicleId: currentVehicle.id,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionCardHorizontal(
                    icon: Icons.cancel,
                    title: 'Finalizar Percurso',
                    onTap: () {
                      if (!inspectionStatus.departureInspectionCompleted ||
                          !inspectionStatus.arrivalInspectionCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'É necessário realizar ambas as vistorias antes de finalizar o percurso'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      _showFinishJourneyDialog();
                    },
                    iconColor: Colors.red,
                    iconBgColor: Colors.red.withOpacity(0.1),
                    isDisabled:
                    !inspectionStatus.departureInspectionCompleted ||
                        !inspectionStatus.arrivalInspectionCompleted,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showFinishJourneyDialog() {
    final journeyProvider =
    Provider.of<JourneyProvider>(context, listen: false);
    final vehicleProvider =
    Provider.of<VehicleProvider>(context, listen: false);
    final journey = journeyProvider.activeJourney;
    final currentVehicle = vehicleProvider.currentVehicle;

    if (currentVehicle == null || journey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há percurso ativo para finalizar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String duration = '0:00 h';
    if (journey.departureTime != null) {
      final difference = DateTime.now().difference(journey.departureTime!);
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      duration = '${hours}:${minutes.toString().padLeft(2, '0')} h';
    }

    final odometerDifference =
        (currentVehicle.odometer ?? 0) - (journey.initialOdometer ?? 0);
    final distance = '${odometerDifference} km';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: FinishJourneyDialog(
            duration: duration,
            distance: distance,
            onFinish: (int odometer) async {
              final inspectionService = InspectionService();
              final result = await journeyProvider.finishJourney(odometer);

              if (result == true) {
                await inspectionService
                    .clearInspectionStatus(currentVehicle.id);

                final fuelProvider =
                Provider.of<FuelProvider>(context, listen: false);
                await fuelProvider.clearTotalLitersForJourney(journey.id);

                setState(() {
                  inspectionStatus = InspectionStatus();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Percurso finalizado com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context); // Fecha o diálogo
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AvailableVehiclesScreen(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Odômetro final inferior ao atual.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildActionCardHorizontal({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF0066CC),
    Color iconBgColor = const Color(0xFFE3F2FD),
    bool hasNotification = false,
    bool isCompleted = false,
    bool isDisabled = false,
  }) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        color: Theme.of(context).cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isDisabled ? Colors.grey : iconColor,
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
                        color: isDisabled
                            ? Colors.grey
                            : Theme.of(context).textTheme.bodyLarge?.color,
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
    return LatLngBounds(
      southwest: LatLng(
        _markers
            .map((m) => m.position.latitude)
            .reduce((a, b) => a < b ? a : b),
        _markers
            .map((m) => m.position.longitude)
            .reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        _markers
            .map((m) => m.position.latitude)
            .reduce((a, b) => a > b ? a : b),
        _markers
            .map((m) => m.position.longitude)
            .reduce((a, b) => a > b ? a : b),
      ),
    );
  }
}