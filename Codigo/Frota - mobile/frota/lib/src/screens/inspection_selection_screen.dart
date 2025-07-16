import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journey_provider.dart';
import '../services/inspection_service.dart';
import '../models/inspection_status.dart';
import 'inspection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InspectionSelectionScreen extends StatefulWidget {
  final String vehicleId;

  const InspectionSelectionScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<InspectionSelectionScreen> createState() =>
      _InspectionSelectionScreenState();
}

class _InspectionSelectionScreenState extends State<InspectionSelectionScreen> {
  final InspectionService _inspectionService = InspectionService();
  bool _isLoading = true;
  bool _departureCompleted = false;
  bool _arrivalCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadInspectionStatus();
  }

  Future<void> _loadInspectionStatus() async {
    // Verifica status online e local
    final prefs = await SharedPreferences.getInstance();
    final localDeparture =
        prefs.getBool('inspection_departure_${widget.vehicleId}') ?? false;
    // Consultar status online
    bool onlineDeparture = await _inspectionService.hasInspectionBeenCompleted(
        widget.vehicleId, 'S');
    bool onlineArrival = await _inspectionService.hasInspectionBeenCompleted(
        widget.vehicleId, 'R');
    setState(() {
      _departureCompleted = onlineDeparture || localDeparture;
      _arrivalCompleted = onlineArrival;
      _isLoading = false;
    });
    // Se ambas as vistorias estiverem completadas, enviar status atualizado para tela principal
    _checkAndReturnStatus();
  }

  void _checkAndReturnStatus() {
    // Se as duas vistorias foram completadas, retornar para a tela principal
    if (_departureCompleted && _arrivalCompleted) {
      // Mostrar mensagem ao usuário
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas as vistorias foram concluídas!'),
          backgroundColor: Colors.green,
        ),
      );

      // Pequeno atraso para garantir que a UI seja atualizada antes de retornar
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.pop(
              context,
              InspectionStatus(
                departureInspectionCompleted: true,
                arrivalInspectionCompleted: true,
              ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Blue header with rounded bottom corners
          Container(
            padding:
                const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 20),
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
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Registrar Vistoria',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadInspectionStatus,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Se não houver nenhuma vistoria para fazer
                          if (_departureCompleted && _arrivalCompleted)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Text(
                                  'Todas as vistorias foram concluídas!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                              ),
                            ),

                          // Vistoria de Saída
                          if (!_departureCompleted) ...[
                            const Text(
                              'Vistoria de Saída',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0066CC),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInspectionCard(
                              context: context,
                              title: 'Registrar',
                              isCompleted: _departureCompleted,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InspectionScreen(
                                      title: 'Vistoria de Saída',
                                      vehicleId: widget.vehicleId,
                                      type: 'S',
                                    ),
                                  ),
                                ).then((_) {
                                  // Recarregar status após retornar
                                  _loadInspectionStatus();
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Vistoria de Chegada
                          if (!_arrivalCompleted) ...[
                            const Text(
                              'Vistoria de Chegada',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0066CC),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInspectionCard(
                              context: context,
                              title: 'Registrar',
                              isCompleted: _arrivalCompleted,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InspectionScreen(
                                      title: 'Vistoria de Chegada',
                                      vehicleId: widget.vehicleId,
                                      type: 'R',
                                    ),
                                  ),
                                ).then((_) {
                                  // Recarregar status após retornar
                                  _loadInspectionStatus();
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionCard({
    required BuildContext context,
    required String title,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF3A3A5C)
              : Colors.grey.shade300,
        ),
      ),
      child: InkWell(
        onTap: isCompleted ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isCompleted
                      ? Theme.of(context).textTheme.bodySmall?.color
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              isCompleted
                  ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFF0066CC),
                      size: 24,
                    )
                  : Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      size: 16,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
