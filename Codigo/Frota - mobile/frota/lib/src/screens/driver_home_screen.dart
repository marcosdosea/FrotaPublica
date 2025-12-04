import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:ui';
import '../models/vehicle.dart';
import '../models/journey.dart';
import '../models/inspection_status.dart';
import '../providers/journey_provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/fuel_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../services/inspection_service.dart';
import '../utils/app_theme.dart';
import '../utils/widgets/action_card.dart';
import '../widgets/vehicle_journey_slider.dart';
import '../widgets/finish_journey_dialog.dart';
import 'available_vehicles_screen.dart';
import 'maintenance_request_screen.dart';
import 'fuel_registration_screen.dart';
import 'inspection_selection_screen.dart';
import 'profile_screen.dart';
import 'map_screen.dart';
import 'offline_sync_screen.dart';
import '../services/offline_sync_service.dart';

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
    with WidgetsBindingObserver, TickerProviderStateMixin {
  InspectionStatus inspectionStatus = InspectionStatus();
  late Vehicle _currentVehicle;
  final InspectionService _inspectionService = InspectionService();
  bool _isRefreshing = false;
  DateTime? _lastRefreshTime;
  bool _isJourneyExpanded = false;
  bool _isVehicleExpanded = false;
  late AnimationController _journeyAnimationController;
  late AnimationController _vehicleAnimationController;
  late Animation<double> _journeyAnimation;
  late Animation<double> _vehicleAnimation;
  final OfflineSyncService _offlineSyncService = OfflineSyncService();
  bool _hasPendingSync = false;

  @override
  void initState() {
    super.initState();
    _currentVehicle = widget.vehicle;
    WidgetsBinding.instance.addObserver(this);

    // Inicializar animações
    _journeyAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _vehicleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _journeyAnimation = CurvedAnimation(
      parent: _journeyAnimationController,
      curve: Curves.easeInOut,
    );
    _vehicleAnimation = CurvedAnimation(
      parent: _vehicleAnimationController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vehicleProvider =
          Provider.of<VehicleProvider>(context, listen: false);
      vehicleProvider.setCurrentVehicle(_currentVehicle);
      _refreshData();
      _checkPendingSync();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _journeyAnimationController.dispose();
    _vehicleAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
      _checkPendingSync();
    }
  }

  Future<void> _checkPendingSync() async {
    try {
      final hasPending = await _offlineSyncService.hasPendingSync();
      if (mounted) {
        setState(() {
          _hasPendingSync = hasPending;
        });
      }
    } catch (e) {
      print('Erro ao verificar sincronização pendente: $e');
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
    if (_isRefreshing) return;

    final now = DateTime.now();
    if (_lastRefreshTime != null &&
        now.difference(_lastRefreshTime!).inSeconds < 2) {
      return;
    }

    _isRefreshing = true;
    _lastRefreshTime = now;

    try {
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
        await fuelProvider.loadTotalLitersForJourney(journey.id,
            vehicleId: _currentVehicle.id);
      }

      await _checkInspectionStatus();
      await _checkPendingSync();
    } catch (e) {
      print('Erro ao atualizar dados: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  void _toggleJourneyExpansion() {
    setState(() {
      _isJourneyExpanded = !_isJourneyExpanded;
    });
    if (_isJourneyExpanded) {
      _journeyAnimationController.forward();
    } else {
      _journeyAnimationController.reverse();
    }
  }

  void _toggleVehicleExpansion() {
    setState(() {
      _isVehicleExpanded = !_isVehicleExpanded;
    });
    if (_isVehicleExpanded) {
      _vehicleAnimationController.forward();
    } else {
      _vehicleAnimationController.reverse();
    }
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
          child: Stack(
            children: [
              // Conteúdo principal
              RefreshIndicator(
                onRefresh: _refreshData,
                child: CustomScrollView(
                  slivers: [
                    // Header com saudação
                    SliverToBoxAdapter(
                      child: _buildHeader(isDark),
                    ),

                    // Cards de informações compactos
                    SliverToBoxAdapter(
                      child: _buildCompactInfoCards(isDark),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppTheme.spacing24),
                    ),
                    // Ações principais
                    SliverToBoxAdapter(
                      child: _buildQuickActions(isDark),
                    ),

                    // Notificações/Lembretes
                    SliverToBoxAdapter(
                      child: _buildNotifications(isDark),
                    ),

                    // Espaço para a navbar fixa
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 30),
                    ),
                  ],
                ),
              ),

              // Navbar fixa na parte inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomNavBar(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppTheme.spacing20,
        left: AppTheme.spacing24,
        right: AppTheme.spacing24,
        bottom: AppTheme.spacing32,
      ),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          final firstName = user?.name?.split(' ').first ?? 'Motorista';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $firstName',
                style: AppTheme.displayMedium.copyWith(
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompactInfoCards(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Column(
        children: [
          // Card do Percurso
          _buildCompactJourneyCard(isDark),
          const SizedBox(height: AppTheme.spacing16),
          // Card do Veículo
          _buildCompactVehicleCard(isDark),
        ],
      ),
    );
  }

  Widget _buildCompactJourneyCard(bool isDark) {
    return Consumer<JourneyProvider>(
      builder: (context, journeyProvider, child) {
        final journey = journeyProvider.activeJourney;

        return AppTheme.modernCard(
          isDark: isDark,
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleJourneyExpansion,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Column(
                  children: [
                    // Header sempre visível
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: const Icon(
                            Icons.route,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                journey == null
                                    ? 'Nenhum percurso ativo'
                                    : 'Percurso Ativo',
                                style: AppTheme.titleMedium.copyWith(
                                  color: isDark
                                      ? AppTheme.darkText
                                      : AppTheme.lightText,
                                ),
                              ),
                              if (journey != null) ...[
                                const SizedBox(height: AppTheme.spacing4),
                                Text(
                                  '${journey.origin} → ${journey.destination}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: isDark
                                        ? AppTheme.darkTextSecondary
                                        : AppTheme.lightTextSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isJourneyExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.expand_more,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),

                    // Conteúdo expandido
                    AnimatedBuilder(
                      animation: _journeyAnimation,
                      builder: (context, child) {
                        return SizeTransition(
                          sizeFactor: _journeyAnimation,
                          child: journey == null
                              ? _buildNoJourneyExpandedContent(isDark)
                              : _buildJourneyExpandedContent(journey, isDark),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoJourneyExpandedContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacing16),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: const Icon(
              Icons.route_outlined,
              size: 24,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            'Inicie um novo percurso para começar',
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

  Widget _buildJourneyExpandedContent(Journey journey, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacing16),
      child: Column(
        children: [
          // Estatísticas
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.timer_outlined,
                  label: 'Duração',
                  value: _formatDuration(journey),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Consumer2<JourneyProvider, VehicleProvider>(
                  builder: (context, journeyProvider, vehicleProvider, child) {
                    final currentVehicle =
                        vehicleProvider.currentVehicle ?? _currentVehicle;
                    final odometerDifference = (currentVehicle.odometer ?? 0) -
                        (journey.initialOdometer ?? 0);

                    return _buildStatItem(
                      icon: Icons.straighten,
                      label: 'Percorridos',
                      value: '$odometerDifference km',
                      isDark: isDark,
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacing16),

          // Botão do mapa
          SizedBox(
            width: double.infinity,
            child: AppTheme.actionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(journey: journey),
                  ),
                );
              },
              isPrimary: true,
              isDark: isDark,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 18),
                  SizedBox(width: AppTheme.spacing8),
                  Text('Ver no Mapa'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactVehicleCard(bool isDark) {
    return AppTheme.modernCard(
      isDark: isDark,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleVehicleExpansion,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            child: Column(
              children: [
                // Header sempre visível
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentVehicle.model,
                            style: AppTheme.titleMedium.copyWith(
                              color: isDark
                                  ? AppTheme.darkText
                                  : AppTheme.lightText,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing4),
                          Text(
                            'Placa: ${_currentVehicle.licensePlate}',
                            style: AppTheme.bodySmall.copyWith(
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isVehicleExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),

                // Conteúdo expandido
                AnimatedBuilder(
                  animation: _vehicleAnimation,
                  builder: (context, child) {
                    return SizeTransition(
                      sizeFactor: _vehicleAnimation,
                      child: _buildVehicleExpandedContent(isDark),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleExpandedContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacing16),
      child: Row(
        children: [
          Expanded(
            child: Consumer<VehicleProvider>(
              builder: (context, vehicleProvider, child) {
                final currentVehicle =
                    vehicleProvider.currentVehicle ?? _currentVehicle;

                return _buildStatItem(
                  icon: Icons.speed,
                  label: 'Odômetro',
                  value: '${currentVehicle.odometer ?? 0} km',
                  isDark: isDark,
                );
              },
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Consumer2<JourneyProvider, FuelProvider>(
              builder: (context, journeyProvider, fuelProvider, child) {
                final journey = journeyProvider.activeJourney;
                double totalLiters = 0.0;

                if (journey != null) {
                  totalLiters = fuelProvider.totalLitersForJourney;
                }

                return _buildStatItem(
                  icon: Icons.local_gas_station,
                  label: 'Abastecidos',
                  value: '${totalLiters.toStringAsFixed(1)}L',
                  isDark: isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurface.withOpacity(0.5)
            : AppTheme.lightSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 18,
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            value,
            style: AppTheme.labelMedium.copyWith(
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Journey journey) {
    final now = DateTime.now();
    final start = journey.departureTime;
    final end = journey.arrivalTime ?? now;
    final duration = end.difference(start);

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Widget _buildQuickActions(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações Rápidas',
            style: AppTheme.headlineMedium.copyWith(
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          // Grid de ações
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            crossAxisCount: 2,
            crossAxisSpacing: AppTheme.spacing16,
            mainAxisSpacing: AppTheme.spacing16,
            childAspectRatio: 1.2,
            children: [
              _buildActionCard(
                icon: Icons.local_gas_station,
                title: 'Abastecimento',
                subtitle: 'Registrar combustível',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FuelRegistrationScreen(
                        vehicleId: _currentVehicle.id,
                      ),
                    ),
                  );

                  // Se o abastecimento foi registrado com sucesso, atualizar os dados
                  if (result == true) {
                    await _refreshData();
                  }
                },
                isDark: isDark,
              ),
              _buildActionCard(
                icon: Icons.checklist,
                title: 'Vistoria',
                subtitle: 'Realizar inspeção',
                hasNotification:
                    !inspectionStatus.departureInspectionCompleted ||
                        !inspectionStatus.arrivalInspectionCompleted,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InspectionSelectionScreen(
                        vehicleId: _currentVehicle.id,
                      ),
                    ),
                  ).then((value) {
                    _refreshData();
                    if (value != null && value is InspectionStatus) {
                      setState(() {
                        inspectionStatus = value;
                      });
                    }
                  });
                },
                isDark: isDark,
              ),
              _buildActionCard(
                icon: Icons.build,
                title: 'Manutenção',
                subtitle: 'Solicitar reparo',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MaintenanceRequestScreen(
                        vehicleId: _currentVehicle.id,
                      ),
                    ),
                  );
                },
                isDark: isDark,
              ),
              _buildActionCard(
                icon: Icons.stop_circle,
                title: 'Finalizar',
                subtitle: 'Encerrar percurso',
                isDestructive: true,
                isDisabled: !inspectionStatus.departureInspectionCompleted ||
                    !inspectionStatus.arrivalInspectionCompleted,
                onTap: () {
                  if (!inspectionStatus.departureInspectionCompleted ||
                      !inspectionStatus.arrivalInspectionCompleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Complete as vistorias antes de finalizar'),
                        backgroundColor: AppTheme.warningColor,
                      ),
                    );
                    return;
                  }
                  _showFinishJourneyDialog();
                },
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool hasNotification = false,
    bool isDestructive = false,
    bool isDisabled = false,
  }) {
    Color iconColor =
        isDestructive ? AppTheme.errorColor : AppTheme.primaryColor;

    if (isDisabled) {
      iconColor =
          isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    }

    return AppTheme.modernCard(
      isDark: isDark,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing12),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: AppTheme.titleMedium.copyWith(
                        color: isDisabled
                            ? (isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary)
                            : (isDark ? AppTheme.darkText : AppTheme.lightText),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),

                // Indicador de notificação
                if (hasNotification)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotifications(bool isDark) {
    // Simular notificações com prioridades
    final notifications = _getNotificationsByPriority();

    return Container(
      width: double.infinity,
      constraints:
          const BoxConstraints(maxWidth: 800), // Max width para computadores
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notificações',
            style: AppTheme.headlineMedium.copyWith(
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          if (notifications.isEmpty)
            SizedBox(
              width: double.infinity,
              child: AppTheme.modernCard(
                isDark: isDark,
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: AppTheme.successColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    Text(
                      'Tudo em ordem!',
                      style: AppTheme.titleMedium.copyWith(
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      'Nenhuma notificação no momento',
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...notifications
                .map((notification) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: AppTheme.spacing8),
                      child: _buildNotificationCard(
                        title: notification['title'],
                        priority: notification['priority'],
                        isDark: isDark,
                      ),
                    ))
                .toList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getNotificationsByPriority() {
    List<Map<String, dynamic>> notifications = [];

    // Adicionar notificações baseadas no estado atual
    if (_currentVehicle.maintenanceIssues != null &&
        _currentVehicle.maintenanceIssues!.isNotEmpty) {
      for (String issue in _currentVehicle.maintenanceIssues!) {
        notifications.add({
          'title': issue,
          'priority': 'high', // Manutenção sempre alta prioridade
        });
      }
    }

    // Verificar vistorias pendentes
    if (!inspectionStatus.departureInspectionCompleted) {
      notifications.add({
        'title': 'Vistoria de saída pendente',
        'priority': 'medium',
      });
    }

    if (!inspectionStatus.arrivalInspectionCompleted) {
      notifications.add({
        'title': 'Vistoria de chegada pendente',
        'priority': 'low',
      });
    }

    // Ordenar por prioridade: high -> medium -> low
    notifications.sort((a, b) {
      const priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
      return priorityOrder[a['priority']]!
          .compareTo(priorityOrder[b['priority']]!);
    });

    return notifications;
  }

  Widget _buildNotificationCard({
    required String title,
    required String priority,
    required bool isDark,
  }) {
    IconData icon;
    Color color;

    switch (priority) {
      case 'high':
        icon = Icons.error_rounded;
        color = AppTheme.errorColor;
        break;
      case 'medium':
        icon = Icons.warning_rounded;
        color = AppTheme.warningColor;
        break;
      default:
        icon = Icons.info_rounded;
        color = AppTheme.primaryColor;
    }

    return AppTheme.modernCard(
      isDark: isDark,
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: isDark ? AppTheme.darkText : AppTheme.lightText,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDark
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    return AppTheme.bottomNavBar(
      isDark: isDark,
      child: Container(
        height: 106,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: Icons.home_rounded,
              label: 'Início',
              isActive: true,
              onTap: () {},
              isDark: isDark,
            ),
            _buildNavItem(
              icon: Icons.map_outlined,
              label: 'Mapa',
              onTap: () {
                final journeyProvider =
                    Provider.of<JourneyProvider>(context, listen: false);
                final journey = journeyProvider.activeJourney;
                if (journey != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(journey: journey),
                    ),
                  );
                }
              },
              isDark: isDark,
            ),
            _buildNavItem(
              icon: Icons.sync,
              label: 'Sincronizar',
              hasNotification: _hasPendingSync,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OfflineSyncScreen(),
                  ),
                ).then((_) => _checkPendingSync());
              },
              isDark: isDark,
            ),
            _buildNavItem(
              icon: Icons.person_rounded,
              label: 'Perfil',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isActive = false,
    bool hasNotification = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 66,
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isActive
                        ? AppTheme.primaryColor
                        : (isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: AppTheme.bodySmall.copyWith(
                      color: isActive
                          ? AppTheme.primaryColor
                          : (isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary),
                      fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Indicador de notificação
            if (hasNotification)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.errorColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFinishJourneyDialog() async {
    // Verificar conectividade antes de abrir o diálogo
    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity != ConnectivityResult.none;

    if (!isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'É necessário estar conectado à internet para finalizar o percurso.'),
            backgroundColor: AppTheme.errorColor,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

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

    if (mounted) {
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

                  // Limpar veículo atual silenciosamente para evitar setState durante build
                  vehicleProvider.clearCurrentVehicleSilently();

                  // Usar addPostFrameCallback para evitar setState durante build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      inspectionStatus = InspectionStatus();
                    });
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Percurso finalizado com sucesso!'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );

                  Navigator.pop(context);

                  // Usar addPostFrameCallback para garantir que a navegação aconteça após o build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
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
                      content: Text('Odômetro final inferior ao atual.'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              },
            ),
          );
        },
      );
    }
  }
}
