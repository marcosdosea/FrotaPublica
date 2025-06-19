import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';
import '../providers/auth_provider.dart';
import 'driver_home_screen.dart';
import 'journey_registration_screen.dart';

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

  @override
  void initState() {
    super.initState();
    // Usar WidgetsBinding para garantir que a chamada ocorra após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicles();
    });
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
    });

    final vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
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
                color: const Color(0xFFF5F5F5),
                child: Column(
                  children: [
                    // Search field - com padding apenas nas laterais e topo
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 16.0, bottom: 16.0),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar Placa ou Modelo',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF0066CC),
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),

                    // Vehicle list
                    Expanded(
                      child: _isLoading && _vehicles.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : _filteredVehicles.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Nenhum veículo encontrado',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      RefreshIndicator(
                                        onRefresh: _loadVehicles,
                                        color: const Color(0xFF0066CC),
                                        child: ListView(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          children: const [
                                            SizedBox(height: 200),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: RefreshIndicator(
                                    onRefresh: () async {
                                      // Mostrar mensagem de feedback
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Atualizando lista de veículos...'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );

                                      await _loadVehicles();

                                      // Informar ao usuário que a lista foi atualizada
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Lista de veículos atualizada!'),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    color: const Color(0xFF0066CC),
                                    displacement: 40,
                                    edgeOffset: 0,
                                    child: ListView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.only(
                                          bottom: 80), // Espaço para o FAB
                                      itemCount: _filteredVehicles.length,
                                      itemBuilder: (context, index) {
                                        final vehicle =
                                            _filteredVehicles[index];
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                              children: [
                                                // Car icon
                                                const Icon(
                                                  Icons.directions_car,
                                                  color: Color(0xFF0066CC),
                                                  size: 28,
                                                ),
                                                const SizedBox(width: 16),

                                                // Vehicle info
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        vehicle.model,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Placa: ${vehicle.licensePlate}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        'Hodômetro: ${vehicle.odometer} km',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                SizedBox(
                                                  width: 80,
                                                  height: 40,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              JourneyRegistrationScreen(
                                                                  vehicle:
                                                                      vehicle),
                                                        ),
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFF0066CC),
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                      elevation: 2,
                                                      textStyle:
                                                          const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    child: const Text('Usar'),
                                                  ),
                                                ),
                                              ],
                                            ),
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
          ],
        ),
      ),
    );
  }
}
