import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/local_database_service.dart';
import '../providers/journey_provider.dart';
import '../providers/vehicle_provider.dart';
import '../utils/app_theme.dart';
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
  int _currentOdometer = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentOdometer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCurrentOdometer();
  }

  @override
  void dispose() {
    odometerController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentOdometer() async {
    final vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);

    final vehicle = vehicleProvider.currentVehicle;

    if (vehicle != null) {
      setState(() {
        _currentOdometer = vehicle.odometer;
        odometerController.text = _currentOdometer.toString();
      });
    } else {
      // Se não houver veículo no provider, tentar buscar do journey provider
      final journeyProvider =
          Provider.of<JourneyProvider>(context, listen: false);
      final journey = journeyProvider.activeJourney;

      if (journey != null) {
        final vehicle = await vehicleProvider.getVehicleById(journey.vehicleId);
        if (vehicle != null) {
          setState(() {
            _currentOdometer = vehicle.odometer;
            odometerController.text = _currentOdometer.toString();
          });
        }
      }
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing8),
        child: AppTheme.modernCard(
          isDark: isDark,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título
                  Text(
                    'Chegou ao seu destino?',
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // Informações do percurso
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Duração: ',
                            style: AppTheme.titleSmall.copyWith(
                              color: isDark
                                  ? AppTheme.darkText
                                  : AppTheme.lightText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.duration,
                              style: AppTheme.bodyLarge.copyWith(
                                color: isDark
                                    ? AppTheme.darkText
                                    : AppTheme.lightText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Row(
                        children: [
                          Text(
                            'Distância Percorrida: ',
                            style: AppTheme.titleSmall.copyWith(
                              color: isDark
                                  ? AppTheme.darkText
                                  : AppTheme.lightText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.distance,
                              style: AppTheme.bodyLarge.copyWith(
                                color: isDark
                                    ? AppTheme.darkText
                                    : AppTheme.lightText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacing20),

                  // Campo Odômetro
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Odômetro Final',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      _buildOdometerField(isDark),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacing20),

                  // Botão Finalizar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: AppTheme.actionButton(
                      onPressed: _isLoading ? () {} : _finishJourney,
                      isPrimary: true,
                      isDark: isDark,
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Finalizar Uso',
                              style: AppTheme.titleMedium.copyWith(
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
    );
  }

  Widget _buildOdometerField(bool isDark) {
    return AppTheme.modernCard(
      isDark: isDark,
      padding: EdgeInsets.zero,
      child: TextFormField(
        controller: odometerController,
        keyboardType: TextInputType.number,
        style: AppTheme.bodyLarge.copyWith(
          color: isDark ? AppTheme.darkText : AppTheme.lightText,
        ),
        decoration: InputDecoration(
          hintText: 'Atual: $_currentOdometer km',
          hintStyle: AppTheme.bodyLarge.copyWith(
            color: isDark
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(AppTheme.spacing20),
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
    );
  }
}
