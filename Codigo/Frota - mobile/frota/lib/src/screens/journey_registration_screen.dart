import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
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
import 'driver_home_screen.dart';

class JourneyRegistrationScreen extends StatefulWidget {
  const JourneyRegistrationScreen({super.key});

  @override
  State<JourneyRegistrationScreen> createState() =>
      _JourneyRegistrationScreenState();
}

class _JourneyRegistrationScreenState extends State<JourneyRegistrationScreen> {
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

  static const String _googleMapsApiKey =
      'AIzaSyCxFxCvXpzIcSL_ck0CQyk2Xc2YvOmiLlc';

  @override
  void initState() {
    super.initState();
    _validateForm();

    // Adicionar listeners aos controllers para validar o formulário
    originController.addListener(_validateForm);
    destinationController.addListener(_validateForm);
    reasonController.addListener(_validateForm);
  }

  @override
  void dispose() {
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Cabeçalho azul com cantos arredondados na parte inferior
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
                  'Registrar Percurso',
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
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Local de Saída',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0066CC),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TypeAheadField<Map<String, dynamic>>(
                      controller: originController,
                      suggestionsCallback: (pattern) =>
                          _getAutocompleteSuggestions(pattern),
                      builder: (context, controller, focusNode) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Informe o local de partida',
                            hintStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF3A3A5C)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF3A3A5C)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Color(0xFF0066CC), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        );
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(suggestion['description'] ?? ''),
                        );
                      },
                      onSelected: (suggestion) {
                        originController.text = suggestion['description'] ?? '';
                        _getPlaceDetails(suggestion['place_id'], true);
                      },
                      emptyBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Nenhum local encontrado.'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Local de Destino',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0066CC),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TypeAheadField<Map<String, dynamic>>(
                      controller: destinationController,
                      suggestionsCallback: (pattern) =>
                          _getAutocompleteSuggestions(pattern),
                      builder: (context, controller, focusNode) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Informe o local de chegada',
                            hintStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF3A3A5C)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF3A3A5C)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Color(0xFF0066CC), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        );
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(suggestion['description'] ?? ''),
                        );
                      },
                      onSelected: (suggestion) {
                        destinationController.text =
                            suggestion['description'] ?? '';
                        _getPlaceDetails(suggestion['place_id'], false);
                      },
                      emptyBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Nenhum local encontrado.'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Motivo do Percurso',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0066CC),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Descreva o motivo do percurso',
                        hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF3A3A5C)
                                    : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF3A3A5C)
                                    : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFF0066CC), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _formIsValid ? _submit : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0066CC),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF22223A)
                                        : Colors.grey.shade300,
                                disabledForegroundColor:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Iniciar Percurso',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
