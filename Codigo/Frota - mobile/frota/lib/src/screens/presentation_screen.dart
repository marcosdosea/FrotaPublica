import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/journey_provider.dart';
import '../providers/vehicle_provider.dart';
import '../screens/driver_home_screen.dart';
import '../screens/available_vehicles_screen.dart';
import 'package:flutter/services.dart';

class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Inicializa o provedor de autenticação se ainda não foi inicializado
    if (!authProvider.isLoading && authProvider.currentUser == null) {
      await authProvider.initialize();
    }

    // Verifica se o usuário está autenticado
    if (authProvider.isAuthenticated) {
      final journeyProvider =
      Provider.of<JourneyProvider>(context, listen: false);

      // Carrega o percurso ativo
      await journeyProvider.loadActiveJourney(authProvider.currentUser!.id);

      if (journeyProvider.hasActiveJourney &&
          journeyProvider.activeJourney != null) {
        // Se tiver um percurso ativo, carrega o veículo
        final vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);
        final vehicle = await vehicleProvider
            .getVehicleById(journeyProvider.activeJourney!.vehicleId);

        if (vehicle != null && mounted) {
          // Navega para a tela principal com o veículo
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DriverHomeScreen(vehicle: vehicle),
            ),
          );
          return;
        }
      }

      if (mounted) {
        // Se não tiver percurso ativo, vai para a tela de veículos disponíveis
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AvailableVehiclesScreen(),
          ),
        );
      }
    } else {
      // Se não estiver autenticado, mantém na tela de apresentação
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Configurar barra de status para esta tela específica
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Ícones pretos
        statusBarBrightness: Brightness.light, // Para iOS
      ),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isChecking
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Imagem 3D no topo se estendendo até a barra de notificações
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.55 + MediaQuery.of(context).padding.top,
              child: Image.asset(
                'assets/img/presentation.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Conteúdo de texto (ocupando o restante da tela)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Reinventamos o\ngerenciamento de\ngrandes frotas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0066CC), // Azul como na imagem
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tenha acesso rápido a\ndiversas funcionalidades',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Botão "Acessar" com estilo similar ao da imagem
                  SizedBox(
                    width:
                    200, // Largura fixa para o botão como na imagem
                    height: 50, // Altura para o botão
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF116AD5), // Azul do botão
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8), // Bordas levemente arredondadas
                        ),
                      ),
                      child: const Text(
                        'Acessar',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
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
}
