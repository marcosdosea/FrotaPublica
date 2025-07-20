import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';
import '../providers/auth_provider.dart';
import 'driver_home_screen.dart';
import 'journey_registration_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/journey_provider.dart';

class AvailableVehiclesScreen extends StatefulWidget {
  const AvailableVehiclesScreen({super.key});

  @override
  State<AvailableVehiclesScreen> createState() =>
      _AvailableVehiclesScreenState();
}

class _AvailableVehiclesScreenState extends State<AvailableVehiclesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  List<Vehicle> _vehicles = [];
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
      // Se voltou online, recarregar dados
      if (result != ConnectivityResult.none) {
        _loadVehicles();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkActiveJourneyAndLoadVehicles();
    });
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = connectivityResult == ConnectivityResult.none;
    });
  }

  Future<void> _checkActiveJourneyAndLoadVehicles() async {
    final journeyProvider =
        Provider.of<JourneyProvider>(context, listen: false);
    final vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Se offline, carregar apenas dados locais
    if (_isOffline) {
      await journeyProvider.loadLocalJourney();
    } else {
      await journeyProvider
          .loadActiveJourney(authProvider.currentUser?.id ?? '');
    }

    // Verificar se há percurso ativo (online ou local)
    if (journeyProvider.activeJourney != null) {
      final vehicle = await vehicleProvider
          .getVehicleById(journeyProvider.activeJourney!.vehicleId);
      if (vehicle != null && mounted) {
        vehicleProvider.setCurrentVehicle(vehicle);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DriverHomeScreen(vehicle: vehicle),
          ),
        );
        return;
      }
    }

    // Se não há percurso ativo, carregar veículos disponíveis
    await _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
    });

    final vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Se offline, não tentar carregar do servidor
      if (_isOffline) {
        setState(() {
          _vehicles = [];
          _isLoading = false;
        });
        return;
      }

      await vehicleProvider.fetchAvailableVehicles(
        currentUser: authProvider.currentUser,
      );

      setState(() {
        _vehicles = vehicleProvider.availableVehicles;
        _isLoading = false;
      });

      // Verificar se há erro no provider
      if (vehicleProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Erro ao carregar veículos: ${vehicleProvider.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar veículos: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  List<Vehicle> get _filteredVehicles {
    if (_searchQuery.isEmpty) {
      return _vehicles;
    }
    return _vehicles.where((vehicle) {
      return vehicle.licensePlate
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          vehicle.model.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Column(
          children: [
            // Indicador de conexão offline
            if (_isOffline)
              Container(
                width: double.infinity,
                color: Colors.red.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.wifi_off_rounded, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Sem conexão com a internet',
                      style: TextStyle(color: Colors.red, fontSize: 15),
                    ),
                  ],
                ),
              ),
            // Blue header with rounded bottom corners
            Container(
              padding: const EdgeInsets.only(
                  top: 60, left: 16, right: 16, bottom: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF116AD5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x29000000),
                    offset: Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Veículos Disponíveis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Main content with light gray background
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    // Search field - com padding apenas nas laterais e topo
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 16.0, bottom: 16.0),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar veículo...',
                            hintStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),

                    // Vehicles list with pull-to-refresh
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadVehicles,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _isOffline
                                ? _buildOfflineMessage()
                                : _filteredVehicles.isEmpty
                                    ? _buildEmptyState()
                                    : _buildVehiclesList(),
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
  }

  Widget _buildOfflineMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Sem conexão',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verifique sua conexão com a internet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum veículo encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Não há veículos disponíveis no momento',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _filteredVehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _filteredVehicles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              final vehicleProvider =
                  Provider.of<VehicleProvider>(context, listen: false);
              vehicleProvider.setCurrentVehicle(vehicle);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JourneyRegistrationScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Vehicle icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF116AD5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: Color(0xFF116AD5),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Vehicle details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.model,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Placa: ${vehicle.licensePlate}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (vehicle.odometer != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Odômetro: ${vehicle.odometer} km',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
