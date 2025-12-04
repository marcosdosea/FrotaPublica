import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../utils/app_theme.dart';

class ExitRegistrationScreen extends StatefulWidget {
  const ExitRegistrationScreen({super.key});

  @override
  State<ExitRegistrationScreen> createState() => _ExitRegistrationScreenState();
}

class _ExitRegistrationScreenState extends State<ExitRegistrationScreen> {
  final TextEditingController odometerController = TextEditingController();
  bool _isSubmitting = false;
  int _currentOdometer = 0;

  @override
  void initState() {
    super.initState();
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
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  Future<void> _registerExit() async {
    if (odometerController.text.isEmpty) {
      _showErrorMessage('Por favor, informe a leitura do odômetro');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simular registro
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      Navigator.pop(context, true);
      _showSuccessMessage('Saída registrada com sucesso!');
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorMessage('Erro ao registrar saída: $e');
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return AppTheme.modernCard(
      isDark: isDark,
      padding: EdgeInsets.zero,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: AppTheme.bodyLarge.copyWith(
          color: isDark ? AppTheme.darkText : AppTheme.lightText,
        ),
        decoration: InputDecoration(
          hintText: hintText,
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
      ),
    );
  }

  Widget _buildFieldSection({
    required String title,
    required Widget child,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            color: isDark ? AppTheme.darkText : AppTheme.lightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacing8),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
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
                  Text(
                    'Registrar Saída',
                    style: AppTheme.headlineMedium.copyWith(
                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTheme.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card de informações
                    AppTheme.modernCard(
                      isDark: isDark,
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusLarge),
                            ),
                            child: const Icon(
                              Icons.exit_to_app_rounded,
                              color: AppTheme.primaryColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          Text(
                            'Registrar Saída',
                            style: AppTheme.headlineMedium.copyWith(
                              color: isDark
                                  ? AppTheme.darkText
                                  : AppTheme.lightText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spacing8),
                          Text(
                            'Registre a leitura do odômetro ao sair do veículo',
                            style: AppTheme.bodyMedium.copyWith(
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacing32),

                    // Campo Odômetro
                    _buildFieldSection(
                      title: 'Leitura do Odômetro',
                      child: _buildTextField(
                        controller: odometerController,
                        hintText:
                            'Informe a leitura atual (Atual: $_currentOdometer km)',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        isDark: isDark,
                      ),
                      isDark: isDark,
                    ),

                    const SizedBox(height: AppTheme.spacing48),

                    // Botão de registro
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: AppTheme.actionButton(
                        onPressed: _isSubmitting ? () {} : _registerExit,
                        isPrimary: true,
                        isDark: isDark,
                        child: _isSubmitting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Registrar Saída',
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
          ],
        ),
      ),
    );
  }
}
