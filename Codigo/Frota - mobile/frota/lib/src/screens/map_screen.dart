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
import '../utils/widgets/action_card.dart';
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

  static const String _googleMapsApiKey =
      'AIzaSyCxFxCvXpzIcSL_ck0CQyk2Xc2YvOmiLlc';

  @override
  void initState() {
    super.initState();
    _setupMapData();
    _checkInspectionStatus();
  }

  void _setupMapData() async {
    _markers.clear();
    _polylines.clear();

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

      _addMarkers(departureLatLng, arrivalLatLng);
      await _getDirectionsRoute(departureLatLng, arrivalLatLng);
    } else {
      print(
          '--- MAP_SCREEN: Coordenadas inválidas ou ausentes. Exibindo mapa de Sergipe.');
    }

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

          _routeDistance = leg['distance']['text'];
          _routeDuration = leg['duration']['text'];

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    LatLng initialPosition = const LatLng(-10.9472, -37.0731);
    double initialZoom = 8.0;

    if (widget.journey.hasValidCoordinates) {
      initialPosition = LatLng(
          widget.journey.originLatitude!, widget.journey.originLongitude!);
      initialZoom = 12.0;
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor:
          isDark ? const Color(0xFF0F0F23) : const Color(0xFFE3F2FD),
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F0F23),
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE3F2FD),
                    Color(0xFFBBDEFB),
                    Color(0xFF90CAF9),
                  ],
                ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                  top: 60, left: 16, right: 16, bottom: 20),
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
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child:
                          _buildMapCard(initialPosition, initialZoom, isDark),
                    ),
                    const SizedBox(height: 32),
                    _buildRegistrosSection(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard(
      LatLng initialPosition, double initialZoom, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildJourneyHeader(isDark),
          const SizedBox(height: 16),
          _buildMapContainer(initialPosition, initialZoom),
          const SizedBox(height: 16),
          _buildOdometerInfo(isDark),
        ],
      ),
    );
  }

  Widget _buildJourneyHeader(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildLocationInfo(
              'Partida', widget.journey.origin ?? 'Não informado', isDark),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildLocationInfo(
              'Destino', widget.journey.destination ?? 'Não informado', isDark,
              alignRight: true),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(String label, String location, bool isDark,
      {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? Colors.white.withOpacity(0.6)
                : Colors.black.withOpacity(0.6),
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
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildMapContainer(LatLng initialPosition, double initialZoom) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF116AD5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOdometerInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Odômetros',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<VehicleProvider>(
          builder: (context, vehicleProvider, child) {
            final currentVehicle = vehicleProvider.currentVehicle;
            return Column(
              children: [
                _infoRow(
                    'Inicial:', '${widget.journey.initialOdometer}km', isDark),
                const SizedBox(height: 4),
                _infoRow(
                    'Final:',
                    '${widget.journey.finalOdometer ?? currentVehicle?.odometer ?? '...'}km',
                    isDark),
                const SizedBox(height: 4),
                _infoRow(
                    'Hora de Saída:',
                    Formatters.formatDateTime(widget.journey.departureTime),
                    isDark),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? Colors.white.withOpacity(0.6)
                    : Colors.black.withOpacity(0.6)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrosSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Atalhos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
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
                  ActionCard(
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
                    isDark: isDark,
                  ),
                  ActionCard(
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
                    isDark: isDark,
                  ),
                ],
              ),
            );
          },
        ),
      ],
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
