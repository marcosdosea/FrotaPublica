import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'services/supplier_service.dart';
import 'services/offline_sync_service.dart';

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
  Timer? _supplierUpdateTimer;
  final OfflineSyncService _offlineSyncService = OfflineSyncService();

  @override
  void initState() {
    super.initState();
    // Inicializa o provider de autenticação
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
      _startTokenRefreshCheck();
      _updateSuppliersOnStart();
      _startSupplierUpdateTimer();
      _initializeOfflineSync();
    });
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    _supplierUpdateTimer?.cancel();
    _offlineSyncService.dispose();
    super.dispose();
  }

  void _startTokenRefreshCheck() {
    // Verificar a cada 10 minutos se o token está válido
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
    // Usar addPostFrameCallback para garantir que a inicialização aconteça após o build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();

      if (authProvider.isAuthenticated) {
        final journeyProvider =
            Provider.of<JourneyProvider>(context, listen: false);
        final vehicleProvider =
            Provider.of<VehicleProvider>(context, listen: false);
        final connectivity = await Connectivity().checkConnectivity();
        final isOffline = connectivity == ConnectivityResult.none;

        if (isOffline) {
          await journeyProvider.loadLocalJourney();
        } else {
          await journeyProvider.loadActiveJourney(authProvider.currentUser!.id);
        }

        if (journeyProvider.hasActiveJourney) {
          final vehicle = await vehicleProvider
              .getVehicleById(journeyProvider.activeJourney!.vehicleId);
          if (vehicle != null) {
            vehicleProvider.setCurrentVehicle(vehicle);
          }
        }
      }
    });
  }

  void _updateSuppliersOnStart() async {
    try {
      await SupplierService().updateLocalSuppliers();
      print('Fornecedores atualizados ao abrir o app.');
    } catch (e) {
      print('Erro ao atualizar fornecedores ao abrir o app: '
          ' [31m$e [0m');
    }
  }

  void _startSupplierUpdateTimer() {
    _supplierUpdateTimer =
        Timer.periodic(const Duration(minutes: 10), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      try {
        await SupplierService().updateLocalSuppliers();
        print('Fornecedores atualizados pelo timer.');
      } catch (e) {
        print('Erro ao atualizar fornecedores pelo timer: '
            '\u001b[31m$e\u001b[0m');
      }
    });
  }

  void _initializeOfflineSync() {
    _offlineSyncService.start();
    print('Serviço de sincronização offline inicializado');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frota App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: AppRouter.routes,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            viewInsets: MediaQuery.of(context).viewInsets,
            viewPadding: MediaQuery.of(context).viewPadding,
          ),
          child: child!,
        );
      },
      onGenerateRoute: (settings) {
        // Intercepta a navegação para verificar se é necessário redirecionar
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // Se não estiver autenticado e não estiver indo para login ou apresentação
        if (!authProvider.isAuthenticated &&
            settings.name != '/login' &&
            settings.name != '/presentation' &&
            settings.name != '/splash') {
          print('Usuário não autenticado. Redirecionando para login.');
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }

        // Verificar redirecionamento para DriverHomeScreen na rota inicial
        if (settings.name == '/splash' && authProvider.isAuthenticated) {
          final journeyProvider =
              Provider.of<JourneyProvider>(context, listen: false);
          final vehicleProvider =
              Provider.of<VehicleProvider>(context, listen: false);

          if (journeyProvider.hasActiveJourney &&
              vehicleProvider.hasCurrentVehicle) {
            print('Redirecionando da splash para DriverHomeScreen.');
            return MaterialPageRoute(
              builder: (_) => DriverHomeScreen(
                  vehicle: vehicleProvider.currentVehicle!),
            );
          }
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
            if (vehicleProvider.hasCurrentVehicle) {
              return MaterialPageRoute(
                builder: (_) => DriverHomeScreen(
                    vehicle: vehicleProvider.currentVehicle!),
              );
            } else {
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
        return null;
      },
    );
  }
}
