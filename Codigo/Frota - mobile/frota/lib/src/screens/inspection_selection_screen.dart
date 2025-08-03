import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/journey_provider.dart';
import '../services/inspection_service.dart';
import '../models/inspection_status.dart';
import 'inspection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/app_theme.dart';

class InspectionSelectionScreen extends StatefulWidget {
  final String vehicleId;

  const InspectionSelectionScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<InspectionSelectionScreen> createState() =>
      _InspectionSelectionScreenState();
}

class _InspectionSelectionScreenState extends State<InspectionSelectionScreen> {
  final InspectionService _inspectionService = InspectionService();
  bool _isLoading = true;
  bool _departureCompleted = false;
  bool _arrivalCompleted = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadInspectionStatus();
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    });
  }

  Future<void> _checkConnectivity() async {
    final connectivity = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = connectivity == ConnectivityResult.none;
    });
  }

  Future<void> _loadInspectionStatus() async {
    // Verifica status online e local
    final prefs = await SharedPreferences.getInstance();
    final localDeparture =
        prefs.getBool('inspection_departure_${widget.vehicleId}') ?? false;
    // Consultar status online
    bool onlineDeparture = await _inspectionService.hasInspectionBeenCompleted(
        widget.vehicleId, 'S');
    bool onlineArrival = await _inspectionService.hasInspectionBeenCompleted(
        widget.vehicleId, 'R');
    setState(() {
      _departureCompleted = onlineDeparture || localDeparture;
      _arrivalCompleted = onlineArrival;
      _isLoading = false;
    });
    // Se ambas as vistorias estiverem completadas, enviar status atualizado para tela principal
    _checkAndReturnStatus();
  }

  void _checkAndReturnStatus() {
    // Se as duas vistorias foram completadas, retornar para a tela principal
    if (_departureCompleted && _arrivalCompleted) {
      // Mostrar mensagem ao usuário
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas as vistorias foram concluídas!'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      // Pequeno atraso para garantir que a UI seja atualizada antes de retornar
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.pop(
              context,
              InspectionStatus(
                departureInspectionCompleted: true,
                arrivalInspectionCompleted: true,
              ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  Expanded(
                    child: Text(
                      'Registrar Vistoria',
                      style: AppTheme.headlineMedium.copyWith(
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await _checkConnectivity();
                        await _loadInspectionStatus();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppTheme.spacing24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Se não houver nenhuma vistoria para fazer
                            if (_departureCompleted && _arrivalCompleted)
                              Center(
                                child: AppTheme.modernCard(
                                  isDark: isDark,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: AppTheme.successColor
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.radiusLarge),
                                        ),
                                        child: const Icon(
                                          Icons.check_circle_outline,
                                          color: AppTheme.successColor,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: AppTheme.spacing16),
                                      Text(
                                        'Todas as vistorias foram concluídas!',
                                        style: AppTheme.titleLarge.copyWith(
                                          color: isDark
                                              ? AppTheme.darkText
                                              : AppTheme.lightText,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: AppTheme.spacing8),
                                      Text(
                                        'Você pode prosseguir com o percurso',
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
                              ),

                            // Vistoria de Saída
                            if (!_departureCompleted) ...[
                              Text(
                                'Vistoria de Saída',
                                style: AppTheme.headlineSmall.copyWith(
                                  color: isDark
                                      ? AppTheme.darkText
                                      : AppTheme.lightText,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing12),
                              _buildInspectionCard(
                                context: context,
                                title: 'Registrar Vistoria de Saída',
                                subtitle:
                                    'Verificar condições antes da partida',
                                icon: Icons.exit_to_app,
                                isCompleted: _departureCompleted,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InspectionScreen(
                                        title: 'Vistoria de Saída',
                                        vehicleId: widget.vehicleId,
                                        type: 'S',
                                      ),
                                    ),
                                  ).then((_) {
                                    // Recarregar status após retornar
                                    _loadInspectionStatus();
                                  });
                                },
                                isDark: isDark,
                              ),
                              const SizedBox(height: AppTheme.spacing24),
                            ],

                            // Vistoria de Chegada (só se online)
                            if (!_arrivalCompleted && !_isOffline) ...[
                              Text(
                                'Vistoria de Chegada',
                                style: AppTheme.headlineSmall.copyWith(
                                  color: isDark
                                      ? AppTheme.darkText
                                      : AppTheme.lightText,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing12),
                              _buildInspectionCard(
                                context: context,
                                title: 'Registrar Vistoria de Chegada',
                                subtitle: 'Verificar condições após o percurso',
                                icon: Icons.home_rounded,
                                isCompleted: _arrivalCompleted,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InspectionScreen(
                                        title: 'Vistoria de Chegada',
                                        vehicleId: widget.vehicleId,
                                        type: 'R',
                                      ),
                                    ),
                                  ).then((_) {
                                    // Recarregar status após retornar
                                    _loadInspectionStatus();
                                  });
                                },
                                isDark: isDark,
                              ),
                            ],

                            // Aviso offline
                            if (_isOffline && !_arrivalCompleted) ...[
                              const SizedBox(height: AppTheme.spacing24),
                              AppTheme.modernCard(
                                isDark: isDark,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(
                                          AppTheme.spacing8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warningColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.radiusSmall),
                                      ),
                                      child: const Icon(
                                        Icons.wifi_off,
                                        color: AppTheme.warningColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.spacing12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Modo Offline',
                                            style: AppTheme.titleSmall.copyWith(
                                              color: isDark
                                                  ? AppTheme.darkText
                                                  : AppTheme.lightText,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: AppTheme.spacing4),
                                          Text(
                                            'A vistoria de chegada só pode ser feita online',
                                            style: AppTheme.bodySmall.copyWith(
                                              color: isDark
                                                  ? AppTheme.darkTextSecondary
                                                  : AppTheme.lightTextSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return AppTheme.modernCard(
      isDark: isDark,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCompleted ? null : onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : icon,
                    color: isCompleted
                        ? AppTheme.successColor
                        : AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.titleMedium.copyWith(
                          color: isCompleted
                              ? (isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary)
                              : (isDark
                                  ? AppTheme.darkText
                                  : AppTheme.lightText),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        isCompleted ? 'Concluída' : subtitle,
                        style: AppTheme.bodySmall.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isCompleted)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
