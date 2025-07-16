import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/inspection_service.dart';
import '../providers/journey_provider.dart';
import '../providers/auth_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/local_database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InspectionScreen extends StatefulWidget {
  final String title;
  final String vehicleId;
  final String type; // "S" (saída) ou "R" (retorno)

  const InspectionScreen({
    super.key,
    required this.title,
    required this.vehicleId,
    required this.type,
  });

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  final TextEditingController problemsController = TextEditingController();
  final InspectionService _inspectionService = InspectionService();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    problemsController.dispose();
    super.dispose();
  }

  Future<void> _registerInspection() async {
    if (problemsController.text.isEmpty) {
      setState(() {
        _errorMessage =
            "Por favor, informe se há problemas ou 'Nenhum' caso não haja.";
      });
      _showErrorMessage(_errorMessage!);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Checar conectividade
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;

      if (!isOnline && widget.type == 'S') {
        // Salvar offline apenas para vistoria de saída
        await LocalDatabaseService().insertVistoriaSaidaOffline({
          'vehicleId': widget.vehicleId,
          'journeyId': Provider.of<JourneyProvider>(context, listen: false)
                  .activeJourney
                  ?.id ??
              '',
          'inspectionData': problemsController.text.trim(),
          'dateTime': DateTime.now().toIso8601String(),
        });
        // Marcar como concluída localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('inspection_departure_${widget.vehicleId}', true);
        if (!mounted) return;
        Navigator.pop(context, true);
        _showSuccessMessage('Registro registrado offline', color: Colors.grey);
        return;
      }

      final result = await _inspectionService.registerInspection(
        vehicleId: widget.vehicleId,
        type: widget.type,
        problems: problemsController.text.trim(),
      );

      if (!mounted) return;

      if (result != null) {
        Navigator.pop(context, true);
        _showSuccessMessage("Vistoria registrada com sucesso!");
      } else {
        setState(() {
          _isSubmitting = false;
          _errorMessage =
              "Não foi possível registrar a vistoria. Tente novamente.";
        });
        _showErrorMessage(_errorMessage!);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _errorMessage = "Erro ao registrar vistoria: $e";
      });
      _showErrorMessage(_errorMessage!);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessMessage(String message, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Problemas Identificados',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0066CC),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: problemsController,
                      maxLines: 5,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Descreva os problemas ou escreva "Nenhum" caso não haja',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.6)
                              : Colors.black.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF1E1E2E) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF3A3A5C)
                                : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF3A3A5C)
                                : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFF0066CC), width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _registerInspection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066CC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Registrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
