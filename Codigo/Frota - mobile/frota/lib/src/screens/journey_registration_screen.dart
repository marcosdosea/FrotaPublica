import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../providers/journey_provider.dart';
import '../providers/auth_provider.dart';
import 'driver_home_screen.dart';

class JourneyRegistrationScreen extends StatefulWidget {
  final Vehicle vehicle;

  const JourneyRegistrationScreen({super.key, required this.vehicle});

  @override
  State<JourneyRegistrationScreen> createState() =>
      _JourneyRegistrationScreenState();
}

class _JourneyRegistrationScreenState extends State<JourneyRegistrationScreen> {
  final TextEditingController originController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  bool _isLoading = false;
  bool _formIsValid = false;

  @override
  void initState() {
    super.initState();
    // Adicionar listeners para atualizar o estado quando o texto mudar
    originController.addListener(_updateFormValidity);
    destinationController.addListener(_updateFormValidity);
    reasonController.addListener(_updateFormValidity);
  }

  void _updateFormValidity() {
    final formIsValid = originController.text.isNotEmpty &&
        destinationController.text.isNotEmpty &&
        reasonController.text.isNotEmpty;
    if (formIsValid != _formIsValid) {
      setState(() {
        _formIsValid = formIsValid;
      });
    }
  }

  @override
  void dispose() {
    originController.removeListener(_updateFormValidity);
    destinationController.removeListener(_updateFormValidity);
    reasonController.removeListener(_updateFormValidity);
    originController.dispose();
    destinationController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                  TextField(
                    controller: originController,
                    decoration: InputDecoration(
                      hintText: 'Informe o local de partida',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
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
                  TextField(
                    controller: destinationController,
                    decoration: InputDecoration(
                      hintText: 'Informe o local de chegada',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
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
                    decoration: InputDecoration(
                      hintText: 'Descreva o motivo do percurso',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
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
                            onPressed: _formIsValid ? _registerJourney : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0066CC),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
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
        ],
      ),
    );
  }

  Future<void> _registerJourney() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final journeyProvider =
          Provider.of<JourneyProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final driverId = authProvider.currentUser?.id ?? '';

      final success = await journeyProvider.startJourney(
        vehicleId: widget.vehicle.id,
        driverId: driverId,
        origin: originController.text,
        destination: destinationController.text,
        initialOdometer: widget.vehicle.odometer,
        reason: reasonController.text,
      );

      if (success) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DriverHomeScreen(vehicle: widget.vehicle),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(journeyProvider.error ?? 'Falha ao iniciar percurso'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
