import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../models/user.dart';
import '../models/vehicle.dart';
import '../providers/journey_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/vehicle_provider.dart';
import '../widgets/keyboard_aware_widget.dart';
import '../utils/app_theme.dart';
import 'driver_home_screen.dart';

class JourneyRegistrationScreen extends StatefulWidget {
  final Vehicle? vehicle;
  const JourneyRegistrationScreen({super.key, this.vehicle});

  @override
  State<JourneyRegistrationScreen> createState() =>
      _JourneyRegistrationScreenState();
}

class _JourneyRegistrationScreenState extends State<JourneyRegistrationScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController originController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  Vehicle? _selectedVehicle;
  double? originLatitude;
  double? originLongitude;
  double? destinationLatitude;
  double? destinationLongitude;
  bool _isLoading = false;
  bool _formIsValid = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const String _googleMapsApiKey =
      'AIzaSyCxFxCvXpzIcSL_ck0CQyk2Xc2YvOmiLlc';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _validateForm();

    // Adicionar listeners aos controllers para validar o formulário
    originController.addListener(_validateForm);
    destinationController.addListener(_validateForm);
    reasonController.addListener(_validateForm);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    
    // Remover listeners dos controllers
    originController.removeListener(_validateForm);
    destinationController.removeListener(_validateForm);
    reasonController.removeListener(_validateForm);

    // Dispose dos controllers
    originController.dispose();
    destinationController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  void _validateForm() {
    if (!mounted) return;

    final isValid = originController.text.isNotEmpty &&
        destinationController.text.isNotEmpty &&
        originLatitude != null &&
        originLongitude != null &&
        destinationLatitude != null &&
        destinationLongitude != null;

    if (_formIsValid != isValid) {
      setState(() {
        _formIsValid = isValid;
      });
    }
  }

  Future<void> _getCurrentLocationForOrigin() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização desabilitado.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada permanentemente.');
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        originLatitude = position.latitude;
        originLongitude = position.longitude;
        originController.text = 'Posição Atual';
        _isLoading = false;
        _validateForm();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter localização: ${e.toString()}')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _getAutocompleteSuggestions(
      String pattern) async {
    if (pattern.isEmpty) return [];
    final autocompleteUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$pattern&key=$_googleMapsApiKey&language=pt_BR&components=country:br');
    try {
      final response = await http.get(autocompleteUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' &&
            data['predictions'] != null &&
            data['predictions'].isNotEmpty) {
          return List<Map<String, dynamic>>.from(data['predictions']);
        }
      }
    } catch (_) {}
    // Fallback: tentar Place Text Search, também filtrando por Brasil
    final textSearchUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$pattern&key=$_googleMapsApiKey&language=pt_BR&region=br');
    try {
      final response = await http.get(textSearchUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' &&
            data['results'] != null &&
            data['results'].isNotEmpty) {
          return List<Map<String, dynamic>>.from(data['results'].map((item) => {
            'description': item['name'] +
                (item['formatted_address'] != null
                    ? ' - ' + item['formatted_address']
                    : ''),
            'place_id': item['place_id'],
          }));
        }
      }
    } catch (_) {}
    return [];
  }

  Future<void> _getPlaceDetails(String placeId, bool isOrigin) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_googleMapsApiKey&language=pt_BR');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final location = result['geometry']['location'];
          setState(() {
            if (isOrigin) {
              originLatitude = location['lat']?.toDouble();
              originLongitude = location['lng']?.toDouble();
            } else {
              destinationLatitude = location['lat']?.toDouble();
              destinationLongitude = location['lng']?.toDouble();
            }
            _validateForm();
          });
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _submit() async {
    if (!_formIsValid || _isLoading) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final journeyProvider =
      Provider.of<JourneyProvider>(context, listen: false);
      final vehicleProvider =
      Provider.of<VehicleProvider>(context, listen: false);

      User? currentUser = authProvider.currentUser;
      final vehicle = vehicleProvider.currentVehicle;
      if (currentUser == null || vehicle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erro: Usuário ou veículo não encontrado')),
        );
        setState(() => _isLoading = false);
        return;
      }

      try {
        final success = await journeyProvider.startJourney(
          vehicleId: vehicle.id.toString(),
          driverId: currentUser.id.toString(),
          origin: originController.text,
          destination: destinationController.text,
          initialOdometer: vehicle.odometer ?? 0,
          reason: reasonController.text,
          originLatitude: originLatitude,
          originLongitude: originLongitude,
          destinationLatitude: destinationLatitude,
          destinationLongitude: destinationLongitude,
        );

        if (success) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DriverHomeScreen(vehicle: vehicle)),
          );
        } else {
          throw Exception('Falha ao iniciar percurso');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark 
                ? AppTheme.backgroundGradientDark 
                : AppTheme.backgroundGradientLight,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + AppTheme.spacing20,
                  left: AppTheme.spacing24,
                  right: AppTheme.spacing24,
                  bottom: AppTheme.spacing32,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing16),
                    Expanded(
                      child: Text(
                        'Registrar Percurso',
                        style: AppTheme.headlineMedium.copyWith(
                          color: isDark ? AppTheme.darkText : AppTheme.lightText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Conteúdo
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppTheme.spacing24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Local de Saída
                            Text(
                              'Local de Saída',
                              style: AppTheme.titleLarge.copyWith(
                                color: isDark ? AppTheme.darkText : AppTheme.lightText,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing8),
                            
                            // Campo de origem
                            AppTheme.modernCard(
                              isDark: isDark,
                              padding: EdgeInsets.zero,
                              child: TypeAheadField<Map<String, dynamic>>(
                                controller: originController,
                                suggestionsCallback: (pattern) =>
                                    _getAutocompleteSuggestions(pattern),
                                builder: (context, controller, focusNode) {
                                  return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    style: AppTheme.bodyLarge.copyWith(
                                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Informe o local de partida',
                                      hintStyle: AppTheme.bodyMedium.copyWith(
                                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(AppTheme.spacing16),
                                    ),
                                  );
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    leading: Icon(
                                      Icons.location_on_rounded,
                                      color: AppTheme.primaryColor,
                                    ),
                                    title: Text(
                                      suggestion['description'] ?? '',
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                      ),
                                    ),
                                  );
                                },
                                onSelected: (suggestion) {
                                  originController.text = suggestion['description'] ?? '';
                                  _getPlaceDetails(suggestion['place_id'], true);
                                },
                                emptyBuilder: (context) => Padding(
                                  padding: const EdgeInsets.all(AppTheme.spacing16),
                                  child: Text(
                                    'Nenhum local encontrado.',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: AppTheme.spacing24),
                            
                            // Local de Destino
                            Text(
                              'Local de Destino',
                              style: AppTheme.titleLarge.copyWith(
                                color: isDark ? AppTheme.darkText : AppTheme.lightText,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing8),
                            
                            // Campo de destino
                            AppTheme.modernCard(
                              isDark: isDark,
                              padding: EdgeInsets.zero,
                              child: TypeAheadField<Map<String, dynamic>>(
                                controller: destinationController,
                                suggestionsCallback: (pattern) =>
                                    _getAutocompleteSuggestions(pattern),
                                builder: (context, controller, focusNode) {
                                  return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    style: AppTheme.bodyLarge.copyWith(
                                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Informe o local de chegada',
                                      hintStyle: AppTheme.bodyMedium.copyWith(
                                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(AppTheme.spacing16),
                                    ),
                                  );
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    leading: Icon(
                                      Icons.location_on_rounded,
                                      color: AppTheme.primaryColor,
                                    ),
                                    title: Text(
                                      suggestion['description'] ?? '',
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                      ),
                                    ),
                                  );
                                },
                                onSelected: (suggestion) {
                                  destinationController.text = suggestion['description'] ?? '';
                                  _getPlaceDetails(suggestion['place_id'], false);
                                },
                                emptyBuilder: (context) => Padding(
                                  padding: const EdgeInsets.all(AppTheme.spacing16),
                                  child: Text(
                                    'Nenhum local encontrado.',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: AppTheme.spacing24),
                            
                            // Motivo do Percurso
                            Text(
                              'Motivo do Percurso',
                              style: AppTheme.titleLarge.copyWith(
                                color: isDark ? AppTheme.darkText : AppTheme.lightText,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing8),
                            
                            // Campo de motivo
                            AppTheme.modernCard(
                              isDark: isDark,
                              padding: EdgeInsets.zero,
                              child: TextField(
                                controller: reasonController,
                                maxLines: 3,
                                style: AppTheme.bodyLarge.copyWith(
                                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Descreva o motivo do percurso',
                                  hintStyle: AppTheme.bodyMedium.copyWith(
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(AppTheme.spacing16),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: AppTheme.spacing40),
                            
                            // Botão de iniciar percurso
                            SizedBox(
                              width: double.infinity,
                              child: _isLoading
                                  ? AppTheme.modernCard(
                                      isDark: isDark,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                          ),
                                        ),
                                      ),
                                    )
                                  : AppTheme.actionButton(
                                      onPressed: _formIsValid ? () => _submit() : () {},
                                      isPrimary: true,
                                      isDark: isDark,
                                      child: Text(
                                        'Iniciar Percurso',
                                        style: AppTheme.labelLarge.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
