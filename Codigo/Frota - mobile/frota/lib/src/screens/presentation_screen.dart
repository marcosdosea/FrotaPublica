import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/journey_provider.dart';
import '../providers/vehicle_provider.dart';
import '../screens/driver_home_screen.dart';
import '../screens/available_vehicles_screen.dart';
import '../utils/app_theme.dart';

class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen>
    with TickerProviderStateMixin {
  bool _isChecking = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
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
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoading && authProvider.currentUser == null) {
      await authProvider.initialize();
    }

    if (authProvider.isAuthenticated) {
      final journeyProvider =
          Provider.of<JourneyProvider>(context, listen: false);

      await journeyProvider.loadActiveJourney(authProvider.currentUser!.id);

      if (journeyProvider.hasActiveJourney &&
          journeyProvider.activeJourney != null) {
        final vehicleProvider =
            Provider.of<VehicleProvider>(context, listen: false);
        final vehicle = await vehicleProvider
            .getVehicleById(journeyProvider.activeJourney!.vehicleId);

        if (vehicle != null && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DriverHomeScreen(vehicle: vehicle),
            ),
          );
          return;
        }
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AvailableVehiclesScreen(),
          ),
        );
      }
    } else {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    // Configurar barra de status
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: _isChecking
          ? Container(
              height: screenHeight,
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppTheme.backgroundGradientDark
                    : AppTheme.backgroundGradientLight,
              ),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
              ),
            )
          : Container(
              height: screenHeight,
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppTheme.backgroundGradientDark
                    : AppTheme.backgroundGradientLight,
              ),
              child: Column(
                children: [
                  // Seção da imagem ocupando toda a largura e incluindo status bar
                  Expanded(
                    flex: 6,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          boxShadow: isDark
                              ? AppTheme.darkShadow
                              : AppTheme.lightShadow,
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          child: Stack(
                            children: [
                              // Imagem de fundo ocupando toda a área
                              Positioned.fill(
                                child: Image.asset(
                                  'assets/img/presentation.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Overlay com gradiente sutil
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Seção de conteúdo adaptativa
                  Expanded(
                    flex: 4,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.08,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 20),

                                    // Título principal com animação
                                    ScaleTransition(
                                      scale: _scaleAnimation,
                                      child: Text(
                                        'Reinventamos o\ngerenciamento de\ngrandes frotas',
                                        textAlign: TextAlign.center,
                                        style: AppTheme.displayLarge.copyWith(
                                          color: isDark
                                              ? AppTheme.darkText
                                              : AppTheme.lightText,
                                          height: 1.2,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: constraints.maxHeight * 0.05),

                                    // Subtítulo
                                    FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: Text(
                                        'Tenha acesso rápido a\ndiversas funcionalidades',
                                        textAlign: TextAlign.center,
                                        style: AppTheme.bodyLarge.copyWith(
                                          color: isDark
                                              ? AppTheme.darkTextSecondary
                                              : AppTheme.lightTextSecondary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: constraints.maxHeight * 0.12),

                                    // Botão moderno com novo design system
                                    ScaleTransition(
                                      scale: _scaleAnimation,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        height: 60,
                                        child: AppTheme.actionButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, '/login');
                                          },
                                          isPrimary: true,
                                          isDark: isDark,
                                          child: Center(
                                            child: Text(
                                              'Acessar',
                                              style: AppTheme.headlineMedium
                                                  .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: constraints.maxHeight * 0.1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
