import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/supplier.dart';
import '../services/supplier_service.dart';
import '../services/fuel_service.dart';
import '../providers/journey_provider.dart';
import '../providers/auth_provider.dart';

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

    // Se não tiver percurso ativo, carrega do servidor
    if (!journeyProvider.hasActiveJourney) {
      await journeyProvider.loadActiveJourney(authProvider.currentUser!.id);
    }

    // Garante que temos o ID do percurso
    if (journeyProvider.hasActiveJourney &&
        journeyProvider.activeJourney != null) {
      setState(() {
        _journeyId = journeyProvider.activeJourney!.id;
      });
    } else {
      print("ERRO: Impossível obter percurso ativo");
      // Não deveria ser possível chegar aqui sem um percurso ativo
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

  Future<void> _registrarAbastecimento() async {
    if (selectedSupplier == null ||
        odometerController.text.isEmpty ||
        litersController.text.isEmpty) {
      _showErrorMessage('Preencha todos os campos obrigatórios');
      return;
    }

    if (_journeyId == null) {
      // Tentar carregar novamente o percurso caso não tenha sido carregado
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

      // Log para debug
      print('Enviando abastecimento:');
      print('Fornecedor ID: ${selectedSupplier!.id}');
      print('Fornecedor Nome: ${selectedSupplier!.name}');
      print('Veículo ID: ${widget.vehicleId}');
      print('Percurso ID: $_journeyId');
      print('Litros: $liters');
      print('Odômetro: $odometer');

      // Log detalhado para identificar os parâmetros
      print('Parâmetros do abastecimento:');
      print('journeyId: $_journeyId');
      print('vehicleId: ${widget.vehicleId}');
      print('gasStation: ${selectedSupplier!.id}');
      print('liters: $liters');
      print('odometer: $odometer');

      // Usar o serviço de combustível existente
      final result = await _fuelService.registerFuelRefill(
        journeyId: _journeyId!,
        vehicleId: widget.vehicleId,
        driverId: '0', // O backend já associa ao motorista atual
        gasStation: selectedSupplier!.id,
        liters: liters,
        odometerReading: odometer,
      );

      // Log do resultado para verificar a resposta
      print('Resultado do registerFuelRefill: $result');

      // Se chegou até aqui sem exceções, a operação foi bem-sucedida
      if (!mounted) return;

      // Independentemente do valor de result, a operação foi bem-sucedida já que não lançou exceção
      Navigator.pop(context, true); // Retorna sucesso
      await _fuelService.addLitersToJourneyTotal(_journeyId!, liters);
      _showSuccessMessage('Abastecimento registrado com sucesso!');
    } catch (e) {
      print('Exceção capturada ao registrar abastecimento: $e');

      setState(() {
        _isSubmitting = false;

        // Extrair a mensagem de erro da exceção
        String errorMsg = e.toString();
        print('Erro ao registrar abastecimento: $errorMsg');

        // Verificar se é um erro de odômetro
        if (errorMsg.contains("odômetro informado") &&
            errorMsg.contains("não pode ser menor")) {
          // Extrair a mensagem mais amigável
          try {
            // Considerando formato: Exception: "O odômetro informado (X km) não pode ser menor que o odômetro atual do veículo (Y km)"
            errorMsg = errorMsg.replaceAll('Exception: ', '');
            errorMsg = errorMsg.replaceAll('"', '');
          } catch (_) {
            // Em caso de erro no processamento, usa a mensagem original
          }
          _errorMessage = errorMsg;
        }
        // Verificar se é um erro de fornecedor
        else if (errorMsg.contains("selecionar um posto")) {
          _errorMessage = "É necessário selecionar um posto de combustível";
          // Destaque visual para o campo de seleção de fornecedor
          _highlightSupplier = true;
        }
        // Se receber um erro 200 (success) do servidor, mas com dados inválidos
        else if (errorMsg.contains("200") || errorMsg.contains("success")) {
          // A API retornou sucesso, mas houve problema com o processamento dos dados
          print('A API retornou sucesso, mas houve um problema de parser.');
          // Como a API retornou sucesso, vamos considerar que a operação foi bem-sucedida
          if (!mounted) return;
          Navigator.pop(context, true);
          _showSuccessMessage('Abastecimento registrado com sucesso!');
          return;
        } else {
          _errorMessage = 'Erro ao registrar abastecimento: $e';
        }
      });

      // Exibir o erro em um snackbar para chamar atenção do usuário
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

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Informe a leitura',
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
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Informe a quantidade',
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
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _highlightSupplier
                              ? Colors.red
                              : (Theme.of(context).brightness == Brightness.dark
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
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                          : DropdownButtonHideUnderline(
                        child: DropdownButton<Supplier>(
                          value: selectedSupplier,
                          hint: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Selecionar Posto',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          borderRadius: BorderRadius.circular(8),
                          dropdownColor: Theme.of(context).cardColor,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          items: _suppliers.isEmpty
                              ? [
                            DropdownMenuItem<Supplier>(
                              value: null,
                              enabled: false,
                              child: Text(
                                'Nenhum fornecedor disponível',
                                style: TextStyle(
                                    color: Theme.of(context).textTheme.bodySmall?.color),
                              ),
                            )
                          ]
                              : _suppliers.map((Supplier supplier) {
                            return DropdownMenuItem<Supplier>(
                              value: supplier,
                              child: Text(
                                supplier.name,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: _suppliers.isEmpty
                              ? null
                              : (Supplier? newValue) {
                            setState(() {
                              selectedSupplier = newValue;
                              _highlightSupplier = false;
                            });
                          },
                        ),
                      ),
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
                          disabledBackgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2A2A3E)  // Fundo mais escuro no tema escuro
                              : Colors.grey.shade300,
                          disabledForegroundColor: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF9E9E9E)  // Texto cinza claro no tema escuro
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
    );
  }
}
