import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../widgets/journey_card.dart';
import '../widgets/finish_journey_dialog.dart';
import '../models/inspection_status.dart';
import '../models/journey.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';
import 'fuel_registration_screen.dart';
import 'inspection_selection_screen.dart';
import 'maintenance_request_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/journey_provider.dart';
import '../services/inspection_service.dart';
import '../providers/fuel_provider.dart';
import 'available_vehicles_screen.dart';
import 'profile_screen.dart';
import 'map_screen.dart';
import '../utils/app_theme.dart';

class DriverHomeScreen extends StatefulWidget {
  final Vehicle vehicle;

  const DriverHomeScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with WidgetsBindingObserver {
  InspectionStatus inspectionStatus = InspectionStatus();
  late Vehicle _currentVehicle;
  final InspectionService _inspectionService = InspectionService();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isRefreshing = false;
  DateTime? _lastRefreshTime;

  @override
  void initState() {
    super.initState();
    _currentVehicle = widget.vehicle;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vehicleProvider =
      Provider.of<VehicleProvider>(context, listen: false);
      vehicleProvider.setCurrentVehicle(_currentVehicle);
      _refreshData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  Future<void> _checkInspectionStatus() async {
    try {
      bool departureCompleted =
      await _inspectionService.hasInspectionBeenCompleted(
        _currentVehicle.id,
        'S',
      );

      bool arrivalCompleted =
      await _inspectionService.hasInspectionBeenCompleted(
        _currentVehicle.id,
        'R',
      );

      if (mounted) {
        setState(() {
          inspectionStatus = InspectionStatus(
            departureInspectionCompleted: departureCompleted,
            arrivalInspectionCompleted: arrivalCompleted,
          );
        });
      }
    } catch (e) {
      print('Erro ao verificar status das vistorias: $e');
    }
  }

  Future<void> _loadActiveJourney() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final journeyProvider =
    Provider.of<JourneyProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await journeyProvider.loadActiveJourney(authProvider.currentUser!.id);
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) {
      print('Refresh já em andamento, ignorando chamada');
      return;
    }

    final now = DateTime.now();
    if (_lastRefreshTime != null &&
        now.difference(_lastRefreshTime!).inSeconds < 2) {
      print('Refresh muito recente, ignorando chamada');
      return;
    }

    _isRefreshing = true;
    _lastRefreshTime = now;

    try {
      print('Iniciando refresh dos dados...');

      await _loadActiveJourney();

      final vehicleProvider =
      Provider.of<VehicleProvider>(context, listen: false);
      final updatedVehicle =
      await vehicleProvider.getVehicleById(_currentVehicle.id);
      if (updatedVehicle != null && mounted) {
        setState(() {
          _currentVehicle = updatedVehicle;
        });
        vehicleProvider.setCurrentVehicle(updatedVehicle);
      }

      final fuelProvider = Provider.of<FuelProvider>(context, listen: false);
      await fuelProvider.loadVehicleRefills(_currentVehicle.id);

      final journeyProvider =
      Provider.of<JourneyProvider>(context, listen: false);
      final journey = journeyProvider.activeJourney;
      if (journey != null) {
        await fuelProvider.loadTotalLitersForJourney(journey.id);
      }

      await _checkInspectionStatus();

      print('Refresh dos dados concluído');
    } catch (e) {
      print('Erro ao atualizar dados: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Cor da barra de notificações igual ao topo do header (Color(0xFF116AD5))
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF116AD5), // Mesma cor do topo do gradiente
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFE3F2FD),
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFF116AD5), // Cor de fundo que aparece na barra de status
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark 
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0F0F23),
                      Color(0xFF1A1A2E),
                      Color(0xFF16213E),
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE3F2FD),
                      Color(0xFFBBDEFB),
                      Color(0xFF90CAF9),
                    ],
                  ),
          ),
          child: Column(
            children: [
              // Container com a cor do header que fica atrás da barra de status
              Container(
                height: MediaQuery.of(context).padding.top,
                color: const Color(0xFF116AD5),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 280.0,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF116AD5),
                                        Color(0xFF116AD5),
                                        Color(0xFF004BA7)
                                      ],
                                      stops: [0.0, 0.5, 1.0],
                                    ),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x29000000),
                                        offset: Offset(0, 3),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 24, right: 24, bottom: 30),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                  const ProfileScreen(),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Consumer<AuthProvider>(
                                        builder:
                                            (context, authProvider, child) {
                                          final user = authProvider.currentUser;
                                          final firstName =
                                              user?.name?.split(' ').first ??
                                                  'Motorista';

                                          return Text(
                                            'Olá, $firstName!',
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Realize aqui todos os registros ao longo do percurso.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 130),
                              ],
                            ),

                            Positioned(
                              top: 180.0,
                              left: 24,
                              right: 24,
                              child: _buildSliderCard(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Padding(
                          padding:
                          const EdgeInsets.only(left: 24.0, right: 24.0),
                          child: Row(
                            children: [
                              Text(
                                'Registros',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          height: 120, // Voltou para 120 para acomodar melhor os ícones
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding:
                            const EdgeInsets.only(left: 24.0, right: 24.0),
                            children: [
                              _buildModernActionCard(
                                icon: Icons.local_gas_station,
                                title: 'Registrar\nAbastecimento',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FuelRegistrationScreen(
                                            vehicleId: _currentVehicle.id,
                                          ),
                                    ),
                                  );
                                },
                                isDark: isDark,
                              ),
                              _buildModernActionCard(
                                icon: Icons.checklist,
                                title: 'Realizar Vistoria',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          InspectionSelectionScreen(
                                            vehicleId: _currentVehicle.id,
                                          ),
                                    ),
                                  ).then((value) {
                                    _refreshData();

                                    if (value != null &&
                                        value is InspectionStatus) {
                                      setState(() {
                                        inspectionStatus = value;
                                      });
                                    }
                                  });
                                },
                                hasNotification: !inspectionStatus
                                    .departureInspectionCompleted ||
                                    !inspectionStatus
                                        .arrivalInspectionCompleted,
                                isCompleted: inspectionStatus
                                    .departureInspectionCompleted &&
                                    inspectionStatus.arrivalInspectionCompleted,
                                isDark: isDark,
                              ),
                              _buildModernActionCard(
                                icon: Icons.build,
                                title: 'Solicitar Manutenção',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MaintenanceRequestScreen(
                                            vehicleId: _currentVehicle.id,
                                          ),
                                    ),
                                  );
                                },
                                isDark: isDark,
                              ),
                              _buildModernActionCard(
                                icon: Icons.cancel,
                                title: 'Finalizar Percurso',
                                onTap: () {
                                  if (!inspectionStatus
                                      .departureInspectionCompleted ||
                                      !inspectionStatus
                                          .arrivalInspectionCompleted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'É necessário realizar ambas as vistorias antes de finalizar o percurso'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  _showFinishJourneyDialog();
                                },
                                iconColor: Colors.red,
                                iconBgColor: Colors.red.withOpacity(0.1),
                                isDisabled: !inspectionStatus
                                    .departureInspectionCompleted ||
                                    !inspectionStatus
                                        .arrivalInspectionCompleted,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        Padding(
                          padding:
                          const EdgeInsets.only(left: 24.0, right: 24.0),
                          child: Row(
                            children: [
                              Text(
                                'Lembretes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_currentVehicle.maintenanceIssues != null &&
                            _currentVehicle.maintenanceIssues!.isNotEmpty)
                          ..._currentVehicle.maintenanceIssues!
                              .map((issue) => _buildReminderCard(
                            title: issue,
                            onTap: () {},
                            isDark: isDark,
                          ))
                              .toList()
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 12.0),
                            child: Center(
                              child: Text(
                                'Nenhum lembrete para este veículo',
                                style: TextStyle(
                                  color: isDark 
                                      ? Colors.white.withOpacity(0.6)
                                      : Colors.black.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),
                      ],
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

  Widget _buildSliderCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 239,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildJourneyCard(),
                  _buildVehicleDataCard(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPageIndicator(0),
                const SizedBox(width: 8),
                _buildPageIndicator(1),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF0066CC)
            : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildVehicleDataCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        // Cor sólida sem transparência
        color: isDark 
            ? const Color(0xFF1E1E2E)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _currentVehicle.model,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Placa: ',
                      style: TextStyle(
                        color: isDark 
                            ? Colors.white.withOpacity(0.6)
                            : Colors.black.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066CC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF0066CC).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _currentVehicle.licensePlate,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066CC).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bar_chart,
                        color: Color(0xFF0066CC),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer2<JourneyProvider, VehicleProvider>(
                      builder:
                          (context, journeyProvider, vehicleProvider, child) {
                        final journey = journeyProvider.activeJourney;
                        final currentVehicle =
                            vehicleProvider.currentVehicle ?? _currentVehicle;
                        final odometerDifference = journey != null
                            ? (currentVehicle.odometer ?? 0) -
                            (journey.initialOdometer ?? 0)
                            : 0;

                        return Text(
                          '${odometerDifference} Km',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF0066CC),
                          ),
                        );
                      },
                    ),
                    Text(
                      'Percorridos',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark 
                            ? Colors.white.withOpacity(0.6)
                            : Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 80,
                  color: isDark
                      ? const Color(0xFF3A3A5C)
                      : Colors.grey[300],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066CC).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_gas_station,
                        color: Color(0xFF0066CC),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer2<JourneyProvider, FuelProvider>(
                      builder: (context, journeyProvider, fuelProvider, child) {
                        final journey = journeyProvider.activeJourney;
                        double totalLiters = 0.0;

                        if (journey != null) {
                          totalLiters = fuelProvider.totalLitersForJourney;
                        }

                        return Text(
                          '${totalLiters.toStringAsFixed(2)} L',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF0066CC),
                          ),
                        );
                      },
                    ),
                    Text(
                      'Abastecidos',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark 
                            ? Colors.white.withOpacity(0.6)
                            : Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<JourneyProvider>(
      builder: (context, journeyProvider, child) {
        final journey = journeyProvider.activeJourney;

        if (journey == null) {
          return Container(
            decoration: BoxDecoration(
              // Cor sólida sem transparência
              color: isDark 
                  ? const Color(0xFF1E1E2E)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.route_outlined,
                    size: 40,
                    color: isDark 
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhum percurso ativo no momento',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark 
                          ? Colors.white.withOpacity(0.6)
                          : Colors.black.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            // Cor sólida sem transparência
            color: isDark 
                ? const Color(0xFF1E1E2E)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066CC).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.route,
                        color: Color(0xFF0066CC),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00C853),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Partida',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark 
                                            ? Colors.white.withOpacity(0.6)
                                            : Colors.black.withOpacity(0.6),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      journey.origin ?? 'Não informado',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF00C853),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF5722),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Destino',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark 
                                            ? Colors.white.withOpacity(0.6)
                                            : Colors.black.withOpacity(0.6),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      journey.destination ?? 'Não informado',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A2A3A)
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0066CC).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.speed,
                                color: Color(0xFF0066CC),
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Odômetro',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: isDark 
                                          ? Colors.white.withOpacity(0.6)
                                          : Colors.black.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${journey.initialOdometer ?? 0} km',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: isDark
                            ? const Color(0xFF3A3A5C)
                            : Colors.grey[300],
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0066CC).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.schedule,
                                color: Color(0xFF0066CC),
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Saída',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: isDark 
                                          ? Colors.white.withOpacity(0.6)
                                          : Colors.black.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    journey.formattedDepartureTime ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (journey == null) {
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapScreen(journey: journey),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066CC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Ver Rota',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFinishJourneyDialog() {
    final journeyProvider =
    Provider.of<JourneyProvider>(context, listen: false);
    final vehicleProvider =
    Provider.of<VehicleProvider>(context, listen: false);
    final journey = journeyProvider.activeJourney;
    final currentVehicle = vehicleProvider.currentVehicle ?? _currentVehicle;

    String duration = '0:00 h';
    if (journey?.departureTime != null) {
      final startTime = journey!.departureTime!;
      final currentTime = DateTime.now();
      final difference = currentTime.difference(startTime);

      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      duration = '${hours}:${minutes.toString().padLeft(2, '0')} h';
    }

    final odometerDifference = journey != null
        ? (currentVehicle.odometer ?? 0) - (journey.initialOdometer ?? 0)
        : 0;
    final distance = '${odometerDifference} km';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: FinishJourneyDialog(
            duration: duration,
            distance: distance,
            onFinish: (int odometer) async {
              final inspectionService = InspectionService();

              final journeyProvider =
              Provider.of<JourneyProvider>(context, listen: false);
              final result = await journeyProvider.finishJourney(odometer);

              if (result == true) {
                await inspectionService
                    .clearInspectionStatus(_currentVehicle.id);

                final fuelProvider =
                Provider.of<FuelProvider>(context, listen: false);
                final journey = journeyProvider.activeJourney;
                if (journey != null) {
                  await fuelProvider.clearTotalLitersForJourney(journey.id);
                }

                setState(() {
                  inspectionStatus = InspectionStatus();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Percurso finalizado com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context);

                Future.delayed(const Duration(milliseconds: 100), () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AvailableVehiclesScreen(),
                    ),
                  );
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Odometro final inferior ao atual.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  // Botões iguais aos da tela do mapa
  Widget _buildModernActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF0066CC),
    Color? iconBgColor,
    bool hasNotification = false,
    bool isCompleted = false,
    bool isDisabled = false,
    required bool isDark,
  }) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark 
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            (iconBgColor ?? iconColor).withOpacity(0.2),
                            (iconBgColor ?? iconColor).withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (iconBgColor ?? iconColor).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: isDisabled ? Colors.grey : iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: isDisabled
                            ? Colors.grey
                            : isDark ? Colors.white : Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (hasNotification)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isCompleted)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0066CC),
                          Color(0xFF004499),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0066CC).withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard({
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark 
              ? const Color(0xFF1E1E2E).withOpacity(0.9)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark 
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF0066CC).withOpacity(0.2),
                            const Color(0xFF0066CC).withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: Color(0xFF0066CC),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: isDark 
                          ? Colors.white.withOpacity(0.6)
                          : Colors.black.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
