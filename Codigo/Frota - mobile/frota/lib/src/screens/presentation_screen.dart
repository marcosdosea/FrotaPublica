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
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Configurar barra de status com ícones escuros
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: _isChecking
          ? Container(
              height: screenHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF0F0F23),
                          const Color(0xFF1A1A2E),
                          const Color(0xFF16213E),
                        ]
                      : [
                          const Color(0xFFE3F2FD),
                          const Color(0xFFBBDEFB),
                          const Color(0xFF90CAF9),
                        ],
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF116AD5)),
                  ),
                ),
              ),
            )
          : Container(
              height: screenHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF0F0F23),
                          const Color(0xFF1A1A2E),
                          const Color(0xFF16213E),
                        ]
                      : [
                          const Color(0xFFE3F2FD),
                          const Color(0xFFBBDEFB),
                          const Color(0xFF90CAF9),
                        ],
                ),
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
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.4)
                                  : Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
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
                                      child: ShaderMask(
                                        shaderCallback: (bounds) =>
                                            LinearGradient(
                                          colors: [
                                            const Color(0xFF116AD5),
                                            const Color(0xFF0066CC),
                                            const Color(0xFF004BA7),
                                          ],
                                        ).createShader(bounds),
                                        child: Text(
                                          'Reinventamos o\ngerenciamento de\ngrandes frotas',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.075,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            height: 1.2,
                                            letterSpacing: -0.5,
                                          ),
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
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.045,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.8)
                                              : Colors.black.withOpacity(0.7),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: constraints.maxHeight * 0.12),

                                    // Botão moderno com efeito glassmorphism
                                    ScaleTransition(
                                      scale: _scaleAnimation,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF116AD5),
                                              Color(0xFF0066CC),
                                              Color(0xFF004BA7),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF116AD5)
                                                  .withOpacity(0.4),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, '/login');
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'Acessar',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
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
