import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/fuel_provider.dart';
import 'providers/inspection_provider.dart';
import 'providers/journey_provider.dart';
import 'providers/maintenance_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/vehicle_provider.dart';
import 'routing/app_router.dart';
import 'utils/app_theme.dart';
import 'utils/api_client.dart';
import 'screens/login_screen.dart';
import 'screens/available_vehicles_screen.dart';
import 'screens/driver_home_screen.dart';
import 'screens/presentation_screen.dart';
import 'providers/theme_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => JourneyProvider()),
        ChangeNotifierProvider(create: (_) => FuelProvider()),
        ChangeNotifierProvider(create: (_) => InspectionProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: AppContent(),
    );
  }
}

class AppContent extends StatefulWidget {
  @override
  _AppContentState createState() => _AppContentState();
}

class _AppContentState extends State<AppContent> {
  Timer? _tokenRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Inicializa o provider de autenticação
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
      _startTokenRefreshCheck();
    });
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    super.dispose();
  }

  void _startTokenRefreshCheck() {
    // Verificar a cada 10 minutos se o token está válido (aumentado de 5 para 10 minutos)
    _tokenRefreshTimer =
        Timer.periodic(const Duration(minutes: 10), (timer) async {
      print('Verificando validade do token...');
      if (!mounted) {
        print('Widget não está montado, cancelando verificação');
        timer.cancel();
        return;
      }

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // Primeiro verifica se ainda está autenticado
        if (!authProvider.isAuthenticated) {
          print('Usuário não está autenticado. Parando verificação de token.');
          return;
        }

        // Usar o método checkAuthenticationStatus que já lida com toda a lógica
        final isStillAuthenticated =
            await authProvider.checkAuthenticationStatus();

        if (!isStillAuthenticated) {
          print('Autenticação perdida. Navegando para login...');
          // Navegar para tela de login se necessário
          if (mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (route) => false);
          }
        } else {
          print('Token ainda é válido. Usuário continua autenticado.');
        }
      } catch (e) {
        print('Erro na verificação de token: $e');
        // Em caso de erro, não cancelar o timer, apenas logar o erro
      }
    });
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();

    if (authProvider.isAuthenticated) {
      // Se o usuário estiver autenticado, verifica se há uma jornada ativa
      final journeyProvider =
          Provider.of<JourneyProvider>(context, listen: false);
      await journeyProvider.loadActiveJourney(authProvider.currentUser!.id);

      if (journeyProvider.hasActiveJourney) {
        // Se houver uma jornada ativa, carrega o veículo dessa jornada
        final vehicleProvider =
            Provider.of<VehicleProvider>(context, listen: false);
        final vehicle = await vehicleProvider
            .getVehicleById(journeyProvider.activeJourney!.vehicleId);

        if (vehicle != null) {
          vehicleProvider.setCurrentVehicle(vehicle);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        return MaterialApp(
          title: 'Frota App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRouter.initialRoute,
          routes: AppRouter.routes,
          builder: (context, child) {
            // Configurações globais para melhorar comportamento do teclado
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                // Evitar que o teclado redimensione a tela
                viewInsets: MediaQuery.of(context).viewInsets,
                // Configurar comportamento do teclado
                viewPadding: MediaQuery.of(context).viewPadding,
              ),
              child: child!,
            );
          },
          onGenerateRoute: (settings) {
            // Intercepta a navegação para verificar se é necessário redirecionar

            // Se não estiver autenticado e não estiver indo para login ou apresentação
            if (!authProvider.isAuthenticated &&
                settings.name != '/login' &&
                settings.name != '/presentation') {
              print('Usuário não autenticado. Redirecionando para login.');
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            }

            if (authProvider.isAuthenticated) {
              final journeyProvider =
                  Provider.of<JourneyProvider>(context, listen: false);
              final vehicleProvider =
                  Provider.of<VehicleProvider>(context, listen: false);

              // Se estiver tentando ir para veículos disponíveis enquanto existe percurso ativo, redireciona
              if (settings.name == '/available_vehicles' &&
                  journeyProvider.hasActiveJourney) {
                print(
                    'Jornada ativa encontrada. Redirecionando para DriverHomeScreen.');
                // Precisamos garantir que temos o veículo antes de redirecionar
                if (vehicleProvider.hasCurrentVehicle) {
                  return MaterialPageRoute(
                    builder: (_) => DriverHomeScreen(
                        vehicle: vehicleProvider.currentVehicle!),
                  );
                } else {
                  // Caso não tenha o veículo carregado, direciona para a tela de apresentação
                  // que vai iniciar o carregamento do veículo corretamente
                  return MaterialPageRoute(
                      builder: (_) => const PresentationScreen());
                }
              }

              // Se não houver percurso ativo e estiver indo para a tela inicial, redireciona para veículos disponíveis
              if (settings.name == '/presentation' &&
                  !journeyProvider.hasActiveJourney) {
                print(
                    'Nenhuma jornada ativa. Redirecionando para veículos disponíveis.');
                return MaterialPageRoute(
                    builder: (_) => const AvailableVehiclesScreen());
              }
            }

            // Processa normalmente se não houver redirecionamento
            return null;
          },
        );
      },
    );
  }
}
