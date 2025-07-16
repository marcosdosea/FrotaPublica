import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/local_database_service.dart';
import '../providers/journey_provider.dart';
import 'package:provider/provider.dart';

class FinishJourneyDialog extends StatefulWidget {
  final String duration;
  final String distance;
  final Function(int) onFinish;

  const FinishJourneyDialog({
    super.key,
    required this.duration,
    required this.distance,
    required this.onFinish,
  });

  @override
  State<FinishJourneyDialog> createState() => _FinishJourneyDialogState();
}

class _FinishJourneyDialogState extends State<FinishJourneyDialog> {
  final TextEditingController odometerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    odometerController.dispose();
    super.dispose();
  }

  Future<void> _finishJourney() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Checar conectividade
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;
      if (!isOnline) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'É necessário estar conectado à internet para finalizar o percurso.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      setState(() {
        _isLoading = true;
      });

      try {
        final odometer = int.parse(odometerController.text);
        await widget.onFinish(odometer);
        // Limpar rota salva localmente
        if (widget.onFinish is Function(int, {String? journeyId})) {
          // Se o callback passar o journeyId, use
          // (não é o caso atual, então vamos buscar do Provider)
        }
        // Buscar o journeyId do percurso ativo
        final journeyProvider =
            Provider.of<JourneyProvider>(context, listen: false);
        final journey = journeyProvider.activeJourney;
        if (journey != null) {
          await LocalDatabaseService().deleteRouteForJourney(journey.id);
        }
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        // Tratar erro
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chegou ao seu destino?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0066CC),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Duração: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    widget.duration,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Distância Percorrida: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    widget.distance,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Odômetro Final',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF0066CC),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: odometerController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  hintText: 'Informe a leitura',
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF3A3A5C)
                          : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF3A3A5C)
                          : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF0066CC), width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe a leitura do odômetro';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, informe um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _finishJourney,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Finalizar Uso',
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
    );
  }
}
