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
  }

  @override
  void dispose() {
    // Remover listeners dos controllers
    originController.removeListener(_validateForm);
    destinationController.removeListener(_validateForm);

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
      String pattern, bool isOrigin) async {
    if (pattern.isEmpty && isOrigin) {
      return [
        {
          'description': 'Usar sua Posição Atual',
          'place_id': 'USE_CURRENT_LOCATION'
        }
      ];
    }
    if (pattern.isEmpty) {
      return [];
    }

    // 1. Tentar autocomplete normal
    final autocompleteUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$pattern&key=$_googleMapsApiKey&language=pt_BR');
    try {
      final response = await http.get(autocompleteUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Google Autocomplete Response: ${response.body}');
        if (data['status'] == 'OK' &&
            data['predictions'] != null &&
            data['predictions'].isNotEmpty) {
          List<Map<String, dynamic>> suggestions =
              List<Map<String, dynamic>>.from(data['predictions']);
          if (isOrigin) {
            suggestions.insert(0, {
              'description': 'Usar sua Posição Atual',
              'place_id': 'USE_CURRENT_LOCATION'
            });
          }
          return suggestions;
        }
      }
    } catch (e) {
      debugPrint('Erro no autocomplete: $e');
    }

    // 2. Fallback: tentar Place Text Search
    final textSearchUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$pattern&key=$_googleMapsApiKey&language=pt_BR');
    try {
      final response = await http.get(textSearchUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Google Text Search Response: ${response.body}');
        if (data['status'] == 'OK' &&
            data['results'] != null &&
            data['results'].isNotEmpty) {
          // Adaptar para o formato esperado pelo autocomplete
          List<Map<String, dynamic>> suggestions =
              List<Map<String, dynamic>>.from(data['results'].map((item) => {
                    'description': item['name'] +
                        (item['formatted_address'] != null
                            ? ' - ' + item['formatted_address']
                            : ''),
                    'place_id': item['place_id'],
                  }));
          if (isOrigin) {
            suggestions.insert(0, {
              'description': 'Usar sua Posição Atual',
              'place_id': 'USE_CURRENT_LOCATION'
            });
          }
          return suggestions;
        }
      }
    } catch (e) {
      debugPrint('Erro no text search: $e');
    }

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
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Percurso iniciado com sucesso!')),
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
    final vehicleProvider = Provider.of<VehicleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Novo Percurso'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : KeyboardAwareScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TypeAheadField<Map<String, dynamic>>(
                      controller: originController,
                      suggestionsCallback: (pattern) =>
                          _getAutocompleteSuggestions(pattern, true),
                      builder: (context, controller, focusNode) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Local de Partida',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Informe o local de partida'
                              : null,
                        );
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          leading: Icon(
                              suggestion['place_id'] == 'USE_CURRENT_LOCATION'
                                  ? Icons.my_location
                                  : Icons.location_on),
                          title: Text(suggestion['description'] ?? ''),
                        );
                      },
                      onSelected: (suggestion) {
                        if (suggestion['place_id'] == 'USE_CURRENT_LOCATION') {
                          _getCurrentLocationForOrigin();
                        } else {
                          originController.text =
                              suggestion['description'] ?? '';
                          _getPlaceDetails(suggestion['place_id'], true);
                        }
                        // Fechar teclado após seleção
                        FocusScope.of(context).unfocus();
                      },
                      emptyBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Nenhum local encontrado.'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TypeAheadField<Map<String, dynamic>>(
                      controller: destinationController,
                      suggestionsCallback: (pattern) =>
                          _getAutocompleteSuggestions(pattern, false),
                      builder: (context, controller, focusNode) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Local de Chegada',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Informe o local de chegada'
                              : null,
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
                        // Fechar teclado após seleção
                        FocusScope.of(context).unfocus();
                      },
                      emptyBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Nenhum local encontrado.'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Motivo (Opcional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        // Fechar teclado ao pressionar done
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _formIsValid ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Iniciar Percurso'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
