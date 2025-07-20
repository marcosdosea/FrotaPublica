import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/journey_provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle.dart';

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
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F23) : const Color(0xFFE3F2FD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/logo.png', width: 120, height: 120),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Carregando...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
