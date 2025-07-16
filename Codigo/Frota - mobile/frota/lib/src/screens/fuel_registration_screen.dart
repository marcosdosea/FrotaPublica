import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/supplier.dart';
import '../services/supplier_service.dart';
import '../services/fuel_service.dart';
import '../providers/journey_provider.dart';
import '../providers/auth_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/local_database_service.dart';

class FuelRegistrationScreen extends StatefulWidget {
  final String vehicleId;

  const FuelRegistrationScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<FuelRegistrationScreen> createState() => _FuelRegistrationScreenState();
}

class _FuelRegistrationScreenState extends State<FuelRegistrationScreen> {
  Supplier? selectedSupplier;
  final TextEditingController odometerController = TextEditingController();
  final TextEditingController litersController = TextEditingController();
  final SupplierService _supplierService = SupplierService();
  final FuelService _fuelService = FuelService();

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _highlightSupplier = false;
  List<Supplier> _suppliers = [];
  String? _errorMessage;
  String? _journeyId;
  bool _isSyncingSuppliers = false;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    _carregarPercursoAtivo();
  }

  Future<void> _carregarPercursoAtivo() async {
    final journeyProvider =
        Provider.of<JourneyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!journeyProvider.hasActiveJourney) {
      await journeyProvider.loadActiveJourney(authProvider.currentUser!.id);
    }

    if (journeyProvider.hasActiveJourney &&
        journeyProvider.activeJourney != null) {
      setState(() {
        _journeyId = journeyProvider.activeJourney!.id;
      });
    } else {
      print("ERRO: Impossível obter percurso ativo");
      Navigator.pop(context);
    }
  }

  Future<void> _loadSuppliers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _highlightSupplier = false;
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

  Future<void> _syncSuppliers() async {
    setState(() {
      _isSyncingSuppliers = true;
    });
    try {
      await _supplierService.updateLocalSuppliers();
      await _loadSuppliers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fornecedores sincronizados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao sincronizar fornecedores: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncingSuppliers = false;
        });
      }
    }
  }

  Future<void> _registrarAbastecimento() async {
    if (selectedSupplier == null ||
        odometerController.text.isEmpty ||
        litersController.text.isEmpty) {
      _showErrorMessage('Preencha todos os campos obrigatórios');
      return;
    }

    if (_journeyId == null) {
      await _carregarPercursoAtivo();
      if (_journeyId == null) {
        _showErrorMessage('Não foi possível identificar o percurso ativo');
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final liters = double.parse(litersController.text);
      final odometer = int.parse(odometerController.text);

      // Buscar maior odômetro já registrado (online e offline)
      int maxOdometer = 0;
      // 1. Odômetro inicial do percurso
      final journeyProvider =
          Provider.of<JourneyProvider>(context, listen: false);
      final journey = journeyProvider.activeJourney;
      if (journey != null) {
        maxOdometer = journey.initialOdometer;
        if (journey.finalOdometer != null &&
            journey.finalOdometer! > maxOdometer) {
          maxOdometer = journey.finalOdometer!;
        }
      }
      // 2. Maior odômetro de abastecimentos online (se disponível)
      final abastecimentosOnline =
          await _fuelService.getFuelRefillsForJourney(_journeyId!);
      for (final ab in abastecimentosOnline) {
        if (ab.odometerReading > maxOdometer) {
          maxOdometer = ab.odometerReading;
        }
      }
      // 3. Maior odômetro de abastecimentos offline
      final maxOffline = await LocalDatabaseService()
          .getMaxOdometerAbastecimentoOffline(widget.vehicleId, _journeyId!);
      if (maxOffline != null && maxOffline > maxOdometer) {
        maxOdometer = maxOffline;
      }
      // 4. Validar
      if (odometer < maxOdometer) {
        _showErrorMessage(
            'O odômetro informado não pode ser menor que o último registrado ($maxOdometer km)');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Checar conectividade
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;

      if (!isOnline) {
        // Salvar offline
        await LocalDatabaseService().insertAbastecimentoOffline({
          'vehicleId': widget.vehicleId,
          'journeyId': _journeyId!,
          'supplierId': selectedSupplier!.id,
          'liters': liters,
          'odometer': odometer,
          'dateTime': DateTime.now().toIso8601String(),
        });
        if (!mounted) return;
        Navigator.pop(context, true);
        _showSuccessMessage('Registro registrado offline', color: Colors.grey);
        return;
      }

      print('Enviando abastecimento:');
      print('Fornecedor ID: ${selectedSupplier!.id}');
      print('Fornecedor Nome: ${selectedSupplier!.name}');
      print('Veículo ID: ${widget.vehicleId}');
      print('Percurso ID: $_journeyId');
      print('Litros: $liters');
      print('Odômetro: $odometer');

      print('Parâmetros do abastecimento:');
      print('journeyId: $_journeyId');
      print('vehicleId: ${widget.vehicleId}');
      print('gasStation: ${selectedSupplier!.id}');
      print('liters: $liters');
      print('odometer: $odometer');

      final result = await _fuelService.registerFuelRefill(
        journeyId: _journeyId!,
        vehicleId: widget.vehicleId,
        driverId: '0',
        gasStation: selectedSupplier!.id,
        liters: liters,
        odometerReading: odometer,
      );

      print('Resultado do registerFuelRefill: $result');

      if (!mounted) return;

      Navigator.pop(context, true);
      await _fuelService.addLitersToJourneyTotal(_journeyId!, liters);
      _showSuccessMessage('Abastecimento registrado com sucesso!');
    } catch (e) {
      print('Exceção capturada ao registrar abastecimento: $e');

      setState(() {
        _isSubmitting = false;

        String errorMsg = e.toString();
        print('Erro ao registrar abastecimento: $errorMsg');

        if (errorMsg.contains("odômetro informado") &&
            errorMsg.contains("não pode ser menor")) {
          try {
            errorMsg = errorMsg.replaceAll('Exception: ', '');
            errorMsg = errorMsg.replaceAll('"', '');
          } catch (_) {
            // Em caso de erro no processamento, usa a mensagem original
          }
          _errorMessage = errorMsg;
        } else if (errorMsg.contains("selecionar um posto")) {
          _errorMessage = "É necessário selecionar um posto de combustível";
          _highlightSupplier = true;
        } else if (errorMsg.contains("200") || errorMsg.contains("success")) {
          print('A API retornou sucesso, mas houve um problema de parser.');
          if (!mounted) return;
          Navigator.pop(context, true);
          _showSuccessMessage('Abastecimento registrado com sucesso!');
          return;
        } else {
          _errorMessage = 'Erro ao registrar abastecimento: $e';
        }
      });

      _showErrorMessage(_errorMessage ?? 'Erro ao registrar abastecimento');
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
  void dispose() {
    odometerController.dispose();
    litersController.dispose();
    super.dispose();
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
                    'Registrar Abastecimento',
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
                        textInputAction: TextInputAction.next,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Informe a leitura',
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
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Informe a quantidade',
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Selecione o Posto',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF0066CC),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E1E2E)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _highlightSupplier
                                      ? Colors.red
                                      : (isDark
                                          ? const Color(0xFF3A3A5C)
                                          : Colors.grey.shade300),
                                  width: _highlightSupplier ? 2 : 1,
                                ),
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
                                                child: const Text(
                                                    'Tentar novamente'),
                                              ),
                                            ],
                                          ),
                                        )
                                      : DropdownButtonHideUnderline(
                                          child: DropdownButton<Supplier>(
                                            value: selectedSupplier,
                                            hint: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                'Selecionar Posto',
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white
                                                          .withOpacity(0.6)
                                                      : Colors.black
                                                          .withOpacity(0.6),
                                                ),
                                              ),
                                            ),
                                            isExpanded: true,
                                            icon: Icon(
                                              Icons.keyboard_arrow_down,
                                              color: isDark
                                                  ? Colors.white
                                                      .withOpacity(0.6)
                                                  : Colors.black
                                                      .withOpacity(0.6),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            dropdownColor: isDark
                                                ? const Color(0xFF1E1E2E)
                                                : Colors.white,
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                            items: _suppliers.isEmpty
                                                ? [
                                                    DropdownMenuItem<Supplier>(
                                                      value: null,
                                                      enabled: false,
                                                      child: Text(
                                                        'Nenhum fornecedor disponível',
                                                        style: TextStyle(
                                                            color: isDark
                                                                ? Colors.white
                                                                    .withOpacity(
                                                                        0.6)
                                                                : Colors.black
                                                                    .withOpacity(
                                                                        0.6)),
                                                      ),
                                                    )
                                                  ]
                                                : _suppliers
                                                    .map((Supplier supplier) {
                                                    return DropdownMenuItem<
                                                        Supplier>(
                                                      value: supplier,
                                                      child: Text(
                                                        supplier.name,
                                                        style: TextStyle(
                                                          color: isDark
                                                              ? Colors.white
                                                              : Colors.black87,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                            onChanged: _suppliers.isEmpty
                                                ? null
                                                : (Supplier? newValue) {
                                                    setState(() {
                                                      selectedSupplier =
                                                          newValue;
                                                      _highlightSupplier =
                                                          false;
                                                    });
                                                  },
                                          ),
                                        ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 48,
                            width: 48,
                            child: IconButton(
                              tooltip: 'Sincronizar fornecedores',
                              onPressed:
                                  _isSyncingSuppliers ? null : _syncSuppliers,
                              icon: _isSyncingSuppliers
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : Icon(Icons.sync,
                                      color: isDark
                                          ? Colors.white
                                          : Color(0xFF0066CC)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (!_isLoading &&
                                  !_isSubmitting &&
                                  selectedSupplier != null &&
                                  odometerController.text.isNotEmpty &&
                                  litersController.text.isNotEmpty)
                              ? _registrarAbastecimento
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066CC),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: isDark
                                ? const Color(0xFF2A2A3E)
                                : Colors.grey.shade300,
                            disabledForegroundColor: isDark
                                ? const Color(0xFF9E9E9E)
                                : Colors.grey.shade600,
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
            ),
          ],
        ),
      ),
    );
  }
}
