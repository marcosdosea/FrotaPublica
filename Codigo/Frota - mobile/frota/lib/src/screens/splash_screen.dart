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
    print('SplashScreen: Iniciando verificação de autenticação...');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    print('SplashScreen: AuthProvider obtido, aguardando inicialização...');
    
    await authProvider.initialize();
    print('SplashScreen: AuthProvider inicializado. Autenticado: ${authProvider.isAuthenticated}');

    if (authProvider.isAuthenticated) {
      print('SplashScreen: Usuário autenticado, verificando percurso ativo...');
      
      // Carregar jornada e veículo, se necessário
      final journeyProvider =
          Provider.of<JourneyProvider>(context, listen: false);
      await journeyProvider.loadActiveJourney(authProvider.currentUser!.id);
      print('SplashScreen: Percurso ativo: '
          '${journeyProvider.activeJourney != null ? 'ENCONTRADO' : 'NÃO ENCONTRADO'}');
      
      if (journeyProvider.activeJourney != null) {
        print('SplashScreen: Percurso ativo encontrado, carregando veículo...');
        
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
          Navigator.pushReplacementNamed(context, '/driver_home');
          return;
        }
      }
      
      print('SplashScreen: Navegando para available_vehicles');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/available_vehicles');
      }
    } else {
      print('SplashScreen: Usuário não autenticado, navegando para presentation');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/presentation');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: screenWidth * 0.4,
          height: screenWidth * 0.4,
          child: Image.asset(
            'assets/img/logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
