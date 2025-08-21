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

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
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
            child: Container(
              width: screenWidth * 0.4,
              height: screenWidth * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                child: Image.asset(
                  'assets/img/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
