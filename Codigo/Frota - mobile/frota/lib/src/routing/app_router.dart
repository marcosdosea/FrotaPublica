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

class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginScreen(),
    '/available_vehicles': (context) => const AvailableVehiclesScreen(),
    '/exit_registration': (context) => const ExitRegistrationScreen(),
    '/fuel_registration': (context) => const FuelRegistrationScreen(),
    '/inspection': (context) => const InspectionScreen(title: 'Vistoria'),
    '/inspection_selection': (context) => const InspectionSelectionScreen(),
    '/maintenance_request': (context) => const MaintenanceRequestScreen(),
    '/presentation': (context) => const PresentationScreen(),
  };

  static String get initialRoute => '/presentation';
}
