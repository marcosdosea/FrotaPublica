import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../services/supplier_service.dart';

class FuelRegistrationScreen extends StatefulWidget {
  const FuelRegistrationScreen({super.key});

  @override
  State<FuelRegistrationScreen> createState() => _FuelRegistrationScreenState();
}

class _FuelRegistrationScreenState extends State<FuelRegistrationScreen> {
  Supplier? selectedSupplier;
  final TextEditingController odometerController = TextEditingController();
  final TextEditingController litersController = TextEditingController();
  final SupplierService _supplierService = SupplierService();

  bool _isLoading = true;
  List<Supplier> _suppliers = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final suppliers = await _supplierService.getAllSuppliers();
      setState(() {
        _suppliers = suppliers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Falha ao carregar fornecedores: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    odometerController.dispose();
    litersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                  'Abastecimento',
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
            child: RefreshIndicator(
              onRefresh: _loadSuppliers,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selecione o Posto',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0066CC),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          : _errorMessage != null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline,
                                          color: Colors.red),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _loadSuppliers,
                                        child: const Text('Tentar novamente'),
                                      ),
                                    ],
                                  ),
                                )
                              : DropdownButtonHideUnderline(
                                  child: DropdownButton<Supplier>(
                                    value: selectedSupplier,
                                    hint: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Text('Selecionar Posto'),
                                    ),
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    borderRadius: BorderRadius.circular(8),
                                    items: _suppliers.isEmpty
                                        ? [
                                            const DropdownMenuItem<Supplier>(
                                              value: null,
                                              enabled: false,
                                              child: Text(
                                                'Nenhum fornecedor disponível',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            )
                                          ]
                                        : _suppliers.map((Supplier supplier) {
                                            return DropdownMenuItem<Supplier>(
                                              value: supplier,
                                              child: Text(supplier.name),
                                            );
                                          }).toList(),
                                    onChanged: _suppliers.isEmpty
                                        ? null
                                        : (Supplier? newValue) {
                                            setState(() {
                                              selectedSupplier = newValue;
                                            });
                                          },
                                  ),
                                ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Leitura do Odômetro',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0066CC),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: odometerController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Informe a leitura',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFF0066CC), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Litros Abastecidos',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0066CC),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: litersController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Informe a quantidade',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFF0066CC), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: !_isLoading &&
                                selectedSupplier != null &&
                                odometerController.text.isNotEmpty &&
                                litersController.text.isNotEmpty
                            ? () {
                                // Implementar lógica de registro com o ID do fornecedor selecionado
                                print(
                                    'Registrando abastecimento com o fornecedor: ${selectedSupplier!.name} (ID: ${selectedSupplier!.id})');
                                Navigator.pop(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066CC),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
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
          ),
        ],
      ),
    );
  }
}
