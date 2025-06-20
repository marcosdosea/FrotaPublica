import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/maintenance_provider.dart';

class MaintenanceRequestScreen extends StatefulWidget {
  final String vehicleId;

  const MaintenanceRequestScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<MaintenanceRequestScreen> createState() =>
      _MaintenanceRequestScreenState();
}

class _MaintenanceRequestScreenState extends State<MaintenanceRequestScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, descreva o problema'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success =
          await context.read<MaintenanceProvider>().createMaintenanceRequest(
                vehicleId: widget.vehicleId,
                description: _descriptionController.text.trim(),
              );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solicitação registrada com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.read<MaintenanceProvider>().error ??
                  'Erro ao registrar solicitação'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
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
                const Text(
                  'Solicitação',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descrição do Problema',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF0066CC),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Informe qual o problema',
                      hintStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? const Color(0xFF3A3A5C)
                              : Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark 
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
                      onPressed: _isSubmitting ? null : _submitRequest,
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
    );
  }
}
