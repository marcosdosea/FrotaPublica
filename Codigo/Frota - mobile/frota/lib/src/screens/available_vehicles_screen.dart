import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/auth_provider.dart';
import '../models/vehicle.dart';
import '../utils/app_theme.dart';
import 'journey_registration_screen.dart';
import 'profile_screen.dart';

class AvailableVehiclesScreen extends StatefulWidget {
  const AvailableVehiclesScreen({super.key});

  @override
  State<AvailableVehiclesScreen> createState() =>
      _AvailableVehiclesScreenState();
}

class _AvailableVehiclesScreenState extends State<AvailableVehiclesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicles();
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  Future<void> _loadVehicles() async {
    final vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);
    await vehicleProvider.loadAvailableVehicles();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                  top: MediaQuery.of(context).padding.top + AppTheme.spacing20,
                  left: AppTheme.spacing24,
                  right: AppTheme.spacing24,
                  bottom: AppTheme.spacing32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              final user = authProvider.currentUser;
                              final firstName =
                                  user?.name?.split(' ').first ?? 'Motorista';

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Olá, $firstName',
                                    style: AppTheme.displayMedium.copyWith(
                                      color: isDark
                                          ? AppTheme.darkText
                                          : AppTheme.lightText,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacing4),
                                  Text(
                                    'Selecione um veículo para começar',
                                    style: AppTheme.bodyLarge.copyWith(
                                      color: isDark
                                          ? AppTheme.darkTextSecondary
                                          : AppTheme.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        // Avatar do usuário
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMedium),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Conteúdo
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Consumer<VehicleProvider>(
                      builder: (context, vehicleProvider, child) {
                        if (vehicleProvider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor),
                            ),
                          );
                        }

                        if (vehicleProvider.error != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusXLarge),
                                  ),
                                  child: const Icon(
                                    Icons.error_outline_rounded,
                                    size: 40,
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacing16),
                                Text(
                                  'Erro ao carregar veículos',
                                  style: AppTheme.titleLarge.copyWith(
                                    color: isDark
                                        ? AppTheme.darkText
                                        : AppTheme.lightText,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacing8),
                                Text(
                                  vehicleProvider.error!,
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: isDark
                                        ? AppTheme.darkTextSecondary
                                        : AppTheme.lightTextSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppTheme.spacing24),
                                AppTheme.actionButton(
                                  onPressed: _loadVehicles,
                                  isPrimary: true,
                                  isDark: isDark,
                                  child: const Text('Tentar Novamente'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (vehicleProvider.availableVehicles.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppTheme.infoColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusXLarge),
                                  ),
                                  child: const Icon(
                                    Icons.directions_car_outlined,
                                    size: 40,
                                    color: AppTheme.infoColor,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacing16),
                                Text(
                                  'Nenhum veículo disponível',
                                  style: AppTheme.titleLarge.copyWith(
                                    color: isDark
                                        ? AppTheme.darkText
                                        : AppTheme.lightText,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacing8),
                                Text(
                                  'Não há veículos disponíveis no momento',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: isDark
                                        ? AppTheme.darkTextSecondary
                                        : AppTheme.lightTextSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: _loadVehicles,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(AppTheme.spacing24),
                            itemCount: vehicleProvider.availableVehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle =
                                  vehicleProvider.availableVehicles[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppTheme.spacing16),
                                child: _buildVehicleCard(vehicle, isDark),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle, bool isDark) {
    return AppTheme.modernCard(
      isDark: isDark,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            // Definir o veículo atual no provider antes de navegar
            final vehicleProvider =
                Provider.of<VehicleProvider>(context, listen: false);
            vehicleProvider.setCurrentVehicle(vehicle);

            // Navegar para a tela de registro de percurso
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    JourneyRegistrationScreen(vehicle: vehicle),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            child: Row(
              children: [
                // Ícone do veículo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),

                const SizedBox(width: AppTheme.spacing16),

                // Informações do veículo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.model,
                        style: AppTheme.titleLarge.copyWith(
                          color:
                              isDark ? AppTheme.darkText : AppTheme.lightText,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        'Placa: ${vehicle.licensePlate}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing8,
                              vertical: AppTheme.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Text(
                              'Disponível',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing8),
                          Text(
                            '${vehicle.odometer ?? 0} km',
                            style: AppTheme.bodySmall.copyWith(
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Seta
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
