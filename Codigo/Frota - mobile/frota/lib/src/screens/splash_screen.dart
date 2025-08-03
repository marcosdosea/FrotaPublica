import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/journey_provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthAndNavigate();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();

    if (authProvider.isAuthenticated) {
      // Carregar jornada e veículo, se necessário
      final journeyProvider =
          Provider.of<JourneyProvider>(context, listen: false);
      await journeyProvider.loadActiveJourney(authProvider.currentUser!.id);
      print('SplashScreen: Percurso ativo: '
          '${journeyProvider.activeJourney != null ? 'ENCONTRADO' : 'NÃO ENCONTRADO'}');
      if (journeyProvider.activeJourney != null) {
        final vehicleProvider =
            Provider.of<VehicleProvider>(context, listen: false);
        final journey = journeyProvider.activeJourney!;
        Vehicle? vehicle =
            await vehicleProvider.getVehicleById(journey.vehicleId);
        print('SplashScreen: Veículo do percurso: '
            '${vehicle != null ? 'ENCONTRADO' : 'NÃO ENCONTRADO'}');
        if (vehicle == null) {
          // Criar objeto mínimo a partir do percurso
          vehicle = Vehicle(
            id: journey.vehicleId,
            model: 'Modelo desconhecido',
            licensePlate: 'Sem placa',
            odometer: journey.initialOdometer ?? 0,
            isAvailable: false,
          );
          print('SplashScreen: Veículo mínimo criado a partir do percurso.');
        }
        if (mounted) {
          vehicleProvider.setCurrentVehicle(vehicle);
          print('SplashScreen: Navegando para driver_home');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/driver_home');
          });
          return;
        }
      }
      print('SplashScreen: Navegando para available_vehicles');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/available_vehicles');
        });
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/presentation');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.backgroundGradientDark
              : AppTheme.backgroundGradientLight,
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AppTheme.modernCard(
                  isDark: isDark,
                  padding: const EdgeInsets.all(AppTheme.spacing32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: screenWidth * 0.3,
                        height: screenWidth * 0.3,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLarge),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLarge),
                          child: Image.asset(
                            'assets/img/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      // Título
                      Text(
                        'Frota Pública',
                        style: AppTheme.displayLarge.copyWith(
                          color:
                              isDark ? AppTheme.darkText : AppTheme.lightText,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Subtítulo
                      Text(
                        'Sistema de Gestão de Frota',
                        style: AppTheme.bodyLarge.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: screenHeight * 0.06),

                      // Loading indicator
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                          strokeWidth: 2,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Texto de carregamento
                      Text(
                        'Carregando...',
                        style: AppTheme.bodyMedium.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
