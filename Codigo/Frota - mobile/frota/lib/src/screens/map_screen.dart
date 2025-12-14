import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/journey.dart';
import '../providers/vehicle_provider.dart';
import '../models/inspection_status.dart';
import '../services/inspection_service.dart';
import 'fuel_registration_screen.dart';
import 'inspection_selection_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/local_database_service.dart';
import '../services/route_service.dart';
import '../utils/app_theme.dart';

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
  final RouteService _routeService = RouteService();
  bool _isLoadingRoute = false;
  String? _routeDistance;
  String? _routeDuration;
  bool _isExpanded = false;

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
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;
      final journeyId = widget.journey.id;

      if (!isOnline) {
        // Tentar carregar rota salva localmente
        final savedRouteJson =
            await LocalDatabaseService().getRouteForJourney(journeyId);
        if (savedRouteJson != null) {
          final routeData = _routeService.parseRouteJson(savedRouteJson);
          if (routeData != null && routeData['status'] == 'OK') {
            _routeDistance = routeData['distance'];
            _routeDuration = routeData['duration'];
            final String encodedPolyline = routeData['polyline'];
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: _decodePolyline(encodedPolyline),
                color: AppTheme.primaryColor,
                width: 5,
              ),
            );
            setState(() {});
            _fitMarkersInView();
            return;
          }
        }
        // Se não houver rota salva, desenhar linha reta
        _drawStraightLine(origin, destination);
        setState(() {});
        _fitMarkersInView();
        return;
      }

      // Online: buscar rota através da API
      print(
          '--- MAP_SCREEN: Buscando rota através da API para percurso: $journeyId');
      final routeJson = await _routeService.getRouteForJourney(journeyId);

      if (routeJson != null) {
        print('--- MAP_SCREEN: Rota obtida da API. Processando...');
        final routeData = _routeService.parseRouteJson(routeJson);

        if (routeData != null && routeData['status'] == 'OK') {
          print(
              '--- MAP_SCREEN: Status da rota é OK. Desenhando rota no mapa.');

          _routeDistance = routeData['distance'];
          _routeDuration = routeData['duration'];
          final String encodedPolyline = routeData['polyline'];

          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: _decodePolyline(encodedPolyline),
              color: AppTheme.primaryColor,
              width: 5,
            ),
          );

          // Salvar rota localmente para uso offline
          await LocalDatabaseService()
              .saveRouteForJourney(journeyId, routeJson);
        } else {
          print(
              '--- MAP_SCREEN: API retornou status: ${routeData?['status'] ?? 'UNKNOWN'}. Desenhando linha reta como fallback.');
          _drawStraightLine(origin, destination);
        }
      } else {
        print(
            '--- MAP_SCREEN: Não foi possível obter rota da API. Desenhando linha reta como fallback.');
        _drawStraightLine(origin, destination);
      }
    } catch (e) {
      print(
          '--- MAP_SCREEN: Erro ao obter rota: $e. Desenhando linha reta como fallback.');
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
        color: AppTheme.primaryColor,
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
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Mapa em tela cheia
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
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
            },
          ),

          // Loading overlay
          if (_isLoadingRoute)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              ),
            ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppTheme.spacing16,
                left: AppTheme.spacing24,
                right: AppTheme.spacing24,
                bottom: AppTheme.spacing20,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkCard.withOpacity(0.8)
                            : AppTheme.lightCard.withOpacity(0.8),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.darkBorder
                              : AppTheme.lightBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing16,
                        vertical: AppTheme.spacing12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkCard.withOpacity(0.8)
                            : AppTheme.lightCard.withOpacity(0.8),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.darkBorder
                              : AppTheme.lightBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        'Percurso',
                        style: AppTheme.titleMedium.copyWith(
                          color:
                              isDark ? AppTheme.darkText : AppTheme.lightText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Painel de informações deslizante
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _isExpanded ? 400 : 200,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusXLarge),
                    topRight: Radius.circular(AppTheme.radiusXLarge),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle do painel
                    Container(
                      margin: const EdgeInsets.only(top: AppTheme.spacing12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Conteúdo do painel
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppTheme.spacing24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildJourneyInfo(isDark),
                            if (_isExpanded) ...[
                              const SizedBox(height: AppTheme.spacing24),
                              _buildRouteStats(isDark),
                              const SizedBox(height: AppTheme.spacing24),
                              _buildQuickActions(isDark),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botões de navegação
          Positioned(
            right: AppTheme.spacing24,
            bottom: _isExpanded ? 420 : 220,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkCard.withOpacity(0.8)
                        : AppTheme.lightCard.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color:
                          isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      onTap: () {
                        if (_mapController != null && _markers.isNotEmpty) {
                          _fitMarkersInView();
                        }
                      },
                      child: Icon(
                        Icons.my_location,
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkCard.withOpacity(0.8)
                        : AppTheme.lightCard.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color:
                          isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      onTap: () {
                        _mapController?.animateCamera(CameraUpdate.zoomIn());
                      },
                      child: Icon(
                        Icons.add,
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkCard.withOpacity(0.8)
                        : AppTheme.lightCard.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color:
                          isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      onTap: () {
                        _mapController?.animateCamera(CameraUpdate.zoomOut());
                      },
                      child: Icon(
                        Icons.remove,
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.route,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Text(
                'Informações do Percurso',
                style: AppTheme.titleLarge.copyWith(
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
              ),
            ),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacing16),

        // Origem e destino
        Row(
          children: [
            Expanded(
              child: _buildLocationInfo(
                'Origem',
                widget.journey.origin,
                Icons.radio_button_checked,
                AppTheme.successColor,
                isDark,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: _buildLocationInfo(
                'Destino',
                widget.journey.destination,
                Icons.location_on,
                AppTheme.errorColor,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationInfo(
      String label, String location, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurface.withOpacity(0.5)
            : AppTheme.lightSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                label,
                style: AppTheme.labelMedium.copyWith(
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            location,
            style: AppTheme.bodyMedium.copyWith(
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRouteStats(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estatísticas',
          style: AppTheme.titleMedium.copyWith(
            color: isDark ? AppTheme.darkText : AppTheme.lightText,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        Consumer<VehicleProvider>(
          builder: (context, vehicleProvider, child) {
            final currentVehicle = vehicleProvider.currentVehicle;
            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.timer_outlined,
                    label: 'Duração',
                    value: _formatDuration(),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.speed,
                    label: 'Odômetro',
                    value:
                        '${widget.journey.finalOdometer ?? currentVehicle?.odometer ?? 0} km',
                    isDark: isDark,
                  ),
                ),
              ],
            );
          },
        ),
        if (_routeDistance != null && _routeDuration != null) ...[
          const SizedBox(height: AppTheme.spacing12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.straighten,
                  label: 'Distância',
                  value: _routeDistance!,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.access_time,
                  label: 'Tempo Est.',
                  value: _routeDuration!,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurface.withOpacity(0.5)
            : AppTheme.lightSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            value,
            style: AppTheme.labelLarge.copyWith(
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration() {
    final now = DateTime.now();
    final start = widget.journey.departureTime;
    final end = widget.journey.arrivalTime ?? now;
    final duration = end.difference(start);

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Widget _buildQuickActions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: AppTheme.titleMedium.copyWith(
            color: isDark ? AppTheme.darkText : AppTheme.lightText,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        Consumer<VehicleProvider>(
          builder: (context, vehicleProvider, child) {
            final currentVehicle = vehicleProvider.currentVehicle;

            return Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.local_gas_station,
                    label: 'Abastecimento',
                    onTap: currentVehicle == null
                        ? null
                        : () {
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
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.checklist,
                    label: 'Vistoria',
                    hasNotification:
                        !inspectionStatus.departureInspectionCompleted ||
                            !inspectionStatus.arrivalInspectionCompleted,
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
                    isDark: isDark,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isDark,
    bool hasNotification = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    label,
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (hasNotification)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.errorColor,
                      shape: BoxShape.circle,
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
