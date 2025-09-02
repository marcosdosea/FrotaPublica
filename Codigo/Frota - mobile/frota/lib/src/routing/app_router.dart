import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/available_vehicles_screen.dart';
import '../screens/driver_home_screen.dart';
import '../screens/exit_registration_screen.dart';
import '../screens/fuel_registration_screen.dart';
import '../screens/inspection_screen.dart';
import '../screens/inspection_selection_screen.dart';
import '../screens/maintenance_request_screen.dart';
import '../screens/presentation_screen.dart';
import '../screens/journey_registration_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/splash_screen.dart';
import '../providers/vehicle_provider.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    '/splash': (context) => const SplashScreen(),
    '/login': (context) => const LoginScreen(),
    '/available_vehicles': (context) => const AvailableVehiclesScreen(),
    '/exit_registration': (context) => const ExitRegistrationScreen(),
    '/driver_home': (context) {
      final vehicleProvider =
          Provider.of<VehicleProvider>(context, listen: false);
      final vehicle = vehicleProvider.currentVehicle;
      if (vehicle == null) {
        // fallback para tela de seleção de veículos
        return const AvailableVehiclesScreen();
      }
      return DriverHomeScreen(vehicle: vehicle);
    },
    '/maintenance_request': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return MaintenanceRequestScreen(vehicleId: args['vehicleId']);
    },
    '/presentation': (context) => const PresentationScreen(),
    '/profile': (context) => const ProfileScreen(),
  };

  static String get initialRoute => '/splash';

  // Custom page route with slide animation
  static Route<T> createRoute<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
