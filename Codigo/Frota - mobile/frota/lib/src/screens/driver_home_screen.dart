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
  // Estado para controlar quais vistorias já foram realizadas
  InspectionStatus inspectionStatus = InspectionStatus();
  late Vehicle _currentVehicle;
  final InspectionService _inspectionService = InspectionService();

  @override
  void initState() {
    super.initState();
    _currentVehicle = widget.vehicle;
    // Registrar observer para detectar mudanças no ciclo de vida da aplicação
    WidgetsBinding.instance.addObserver(this);
    // Atualizar o veículo atual no provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vehicleProvider =
          Provider.of<VehicleProvider>(context, listen: false);
      vehicleProvider.setCurrentVehicle(_currentVehicle);

      // Carregar percurso ativo e verificar status das vistorias
      _refreshData();
    });
  }

  @override
  void dispose() {
    // Cancelar o observer ao destruir o widget
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Não atualizar aqui para evitar múltiplas atualizações
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Quando o app volta para o foreground, atualizar dados
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  // Método para verificar o status das vistorias
  Future<void> _checkInspectionStatus() async {
    try {
      // Verificar vistoria de saída
      bool departureCompleted =
          await _inspectionService.hasInspectionBeenCompleted(
        _currentVehicle.id,
        'S',
      );

      // Verificar vistoria de retorno
      bool arrivalCompleted =
          await _inspectionService.hasInspectionBeenCompleted(
        _currentVehicle.id,
        'R',
      );

      // Evitar atualização se o widget foi desmontado
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

  // Método para atualizar todos os dados da tela
  Future<void> _refreshData() async {
    try {
      // Carregar percurso ativo
      await _loadActiveJourney();

      // Atualizar o veículo atual
      final vehicleProvider =
          Provider.of<VehicleProvider>(context, listen: false);
      final updatedVehicle =
          await vehicleProvider.getVehicleById(_currentVehicle.id);
      if (updatedVehicle != null) {
        setState(() {
          _currentVehicle = updatedVehicle;
        });
        vehicleProvider.setCurrentVehicle(updatedVehicle);
      }

      // Carregar abastecimentos do veículo
      final fuelProvider = Provider.of<FuelProvider>(context, listen: false);
      await fuelProvider.loadVehicleRefills(_currentVehicle.id);

      // Carregar total de litros abastecidos do percurso ativo
      final journeyProvider =
          Provider.of<JourneyProvider>(context, listen: false);
      final journey = journeyProvider.activeJourney;
      if (journey != null) {
        await fuelProvider.loadTotalLitersForJourney(journey.id);
      }

      // Verificar status das vistorias
      await _checkInspectionStatus();
    } catch (e) {
      print('Erro ao atualizar dados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definindo a cor da barra de status para combinar com o header
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF116AD5), // Mesma cor do topo do header
      statusBarIconBrightness:
          Brightness.light, // Ícones claros na barra de status
    ));

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // Cor de fundo que aparecerá na área da barra de notificações
        backgroundColor: const Color(0xFF116AD5),
        body: Column(
          children: [
            // Container com a cor do header que fica atrás da barra de status
            Container(
              height: MediaQuery.of(context).padding.top,
              color: const Color(0xFF116AD5),
            ),
            // Conteúdo scrollável
            Expanded(
              child: Container(
                // Cor de fundo do conteúdo principal
                color: const Color(0xFFF5F5F5),
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Blue header - agora parte do conteúdo scrollável
                        Stack(
                          clipBehavior: Clip
                              .none, // Permite que o card ultrapasse os limites do Stack
                          children: [
                            // Blue header
                            Container(
                              width: double.infinity,
                              height:
                                  330.0, // Altura do header conforme o design
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFF116AD5),
                                    Color(0xFF116AD5),
                                    Color(0xFF004BA7)
                                  ],
                                  stops: [
                                    0.0,
                                    0.5,
                                    1.0
                                  ], // Constant color until 50%, then gradient
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
                                  top: 60, left: 24, right: 24, bottom: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Olá, Motorista!',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Realize aqui todos os registros ao longo do percurso',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Card do veículo sobreposto ao header
                            Positioned(
                              left: 24,
                              right: 24,
                              bottom:
                                  -80, // Valor negativo para sobrepor o card ao header
                              child: Card(
                                color: Colors.white,
                                elevation: 4,
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _currentVehicle.model,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                'Placa: ',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                _currentVehicle.licensePlate,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF0066CC)
                                                      .withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.bar_chart,
                                                  color: Color(0xFF0066CC),
                                                  size: 28,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Consumer2<JourneyProvider,
                                                  VehicleProvider>(
                                                builder: (context,
                                                    journeyProvider,
                                                    vehicleProvider,
                                                    child) {
                                                  final journey =
                                                      journeyProvider
                                                          .activeJourney;
                                                  final currentVehicle =
                                                      vehicleProvider
                                                              .currentVehicle ??
                                                          _currentVehicle;
                                                  final odometerDifference =
                                                      journey != null
                                                          ? (currentVehicle
                                                                      .odometer ??
                                                                  0) -
                                                              (journey.initialOdometer ??
                                                                  0)
                                                          : 0;

                                                  return Text(
                                                    '${odometerDifference} Km',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: Color(0xFF0066CC),
                                                    ),
                                                  );
                                                },
                                              ),
                                              const Text(
                                                'Percorridos',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: 1,
                                            height: 80,
                                            color: Colors.grey[300],
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF0066CC)
                                                      .withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.local_gas_station,
                                                  color: Color(0xFF0066CC),
                                                  size: 28,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Consumer2<JourneyProvider,
                                                  FuelProvider>(
                                                builder: (context,
                                                    journeyProvider,
                                                    fuelProvider,
                                                    child) {
                                                  final journey =
                                                      journeyProvider
                                                          .activeJourney;
                                                  double totalLiters = 0.0;

                                                  if (journey != null) {
                                                    totalLiters = fuelProvider
                                                        .totalLitersForJourney;
                                                  }

                                                  return Text(
                                                    '${totalLiters.toStringAsFixed(2)} L',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: Color(0xFF0066CC),
                                                    ),
                                                  );
                                                },
                                              ),
                                              const Text(
                                                'Abastecidos',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Espaço para compensar a sobreposição do card
                        const SizedBox(height: 100),

                        // Card de percurso
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Consumer<JourneyProvider>(
                            builder: (context, journeyProvider, child) {
                              final journey = journeyProvider.activeJourney;

                              if (journey == null) {
                                // Caso não tenha percurso ativo, mostrar mensagem
                                return const Card(
                                  color: Colors.white,
                                  elevation: 2,
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Text(
                                        'Nenhum percurso ativo no momento',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return JourneyCard(
                                journey: journey,
                                onTap: () {
                                  // Ação ao clicar no card - poderia mostrar detalhes
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Registros section
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 24.0, right: 24.0),
                          child: Row(
                            children: const [
                              Text(
                                'Registros',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Horizontal scrollable list of action cards
                        SizedBox(
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.only(left: 24.0, right: 24.0),
                            children: [
                              _buildActionCardHorizontal(
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
                              ),
                              _buildActionCardHorizontal(
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
                                    // Sempre atualizar os dados ao retornar da tela de inspeção
                                    _refreshData();

                                    // Além disso, atualizar o estado se a vistoria foi realizada
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
                              ),
                              _buildActionCardHorizontal(
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
                              ),
                              _buildActionCardHorizontal(
                                icon: Icons.cancel,
                                title: 'Finalizar Percurso',
                                onTap: () {
                                  // Verificar se ambas as vistorias foram realizadas
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
                                // Desabilitar o botão se as vistorias não foram feitas
                                isDisabled: !inspectionStatus
                                        .departureInspectionCompleted ||
                                    !inspectionStatus
                                        .arrivalInspectionCompleted,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        Padding(
                          padding:
                              const EdgeInsets.only(left: 24.0, right: 24.0),
                          child: Row(
                            children: const [
                              Text(
                                'Lembretes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Mostra os problemas de manutenção do veículo selecionado
                        if (_currentVehicle.maintenanceIssues != null &&
                            _currentVehicle.maintenanceIssues!.isNotEmpty)
                          ..._currentVehicle.maintenanceIssues!
                              .map((issue) => _buildReminderCard(
                                    title: issue,
                                    onTap: () {},
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
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                        // Espaço extra no final para melhor scroll
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para mostrar o diálogo de finalização de percurso
  void _showFinishJourneyDialog() {
    // Obter dados do percurso e veículo
    final journeyProvider =
        Provider.of<JourneyProvider>(context, listen: false);
    final vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);
    final journey = journeyProvider.activeJourney;
    final currentVehicle = vehicleProvider.currentVehicle ?? _currentVehicle;

    // Calcular duração do percurso
    String duration = '0:00 h';
    if (journey?.departureTime != null) {
      final startTime = journey!.departureTime!;
      final currentTime = DateTime.now();
      final difference = currentTime.difference(startTime);

      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      duration = '${hours}:${minutes.toString().padLeft(2, '0')} h';
    }

    // Calcular distância percorrida
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
              // Obter instância do InspectionService para limpar vistorias
              final inspectionService = InspectionService();

              // Finalizar o percurso usando o JourneyProvider
              final journeyProvider =
                  Provider.of<JourneyProvider>(context, listen: false);
              final result = await journeyProvider.finishJourney(odometer);

              if (result == true) {
                // Limpar as vistorias salvas localmente
                await inspectionService
                    .clearInspectionStatus(_currentVehicle.id);

                // Limpar o total de litros abastecidos do percurso ativo
                final fuelProvider =
                    Provider.of<FuelProvider>(context, listen: false);
                final journey = journeyProvider.activeJourney;
                if (journey != null) {
                  await fuelProvider.clearTotalLitersForJourney(journey.id);
                }

                // Resetar o status das vistorias na tela
                setState(() {
                  inspectionStatus = InspectionStatus();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Percurso finalizado com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Fechar o modal antes de redirecionar
                Navigator.pop(context);

                // Redirecionar para a tela de veículos disponíveis após fechar o modal
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

  // Horizontal action card for the carousel
  Widget _buildActionCardHorizontal({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF0066CC),
    Color iconBgColor = const Color(0xFFE3F2FD),
    bool hasNotification = false,
    bool isCompleted = false,
    bool isDisabled = false,
  }) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isDisabled ? Colors.grey : iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: isDisabled ? Colors.grey : Colors.black87,
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
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              if (isCompleted)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0066CC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
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
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              const Icon(
                Icons.notifications,
                color: Color(0xFF0066CC),
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
