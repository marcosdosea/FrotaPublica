import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/supplier.dart';
import '../services/supplier_service.dart';
import '../services/fuel_service.dart';
import '../providers/journey_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/vehicle_provider.dart';
import '../utils/app_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/local_database_service.dart';
import '../models/vehicle.dart';

class FuelRegistrationScreen extends StatefulWidget {
  final String vehicleId;

  const FuelRegistrationScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<FuelRegistrationScreen> createState() => _FuelRegistrationScreenState();
}

class _FuelRegistrationScreenState extends State<FuelRegistrationScreen>
    with TickerProviderStateMixin {
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
  int _currentOdometer = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSuppliers();
    _carregarPercursoAtivo();
    _loadCurrentOdometer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarregar odômetro quando as dependências mudarem (ex: quando retornar de outra tela)
    _loadCurrentOdometer();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    odometerController.dispose();
    litersController.dispose();
    super.dispose();
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

  Future<void> _loadCurrentOdometer() async {
    final vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);

    // Tentar obter o veículo atualizado do provider
    Vehicle? currentVehicle = vehicleProvider.currentVehicle;

    // Se não houver veículo no provider, tentar buscar pelo ID
    if (currentVehicle == null || currentVehicle.id != widget.vehicleId) {
      currentVehicle = await vehicleProvider.getVehicleById(widget.vehicleId);
    }

    if (currentVehicle != null) {
      setState(() {
        _currentOdometer = currentVehicle!.odometer;
      });
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
        // Reset selectedSupplier para evitar problemas com valores não encontrados
        selectedSupplier = null;
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
    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity != ConnectivityResult.none;
    if (!isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Sem conexão. Conecte-se à internet para sincronizar fornecedores.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }
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
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao sincronizar fornecedores: $e'),
            backgroundColor: AppTheme.errorColor,
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

      int maxOdometer = 0;
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

      final abastecimentosOnline =
          await _fuelService.getFuelRefillsForJourney(_journeyId!);
      for (final ab in abastecimentosOnline) {
        if (ab.odometerReading > maxOdometer) {
          maxOdometer = ab.odometerReading;
        }
      }

      final maxOffline = await LocalDatabaseService()
          .getMaxOdometerAbastecimentoOffline(widget.vehicleId, _journeyId!);
      if (maxOffline != null && maxOffline > maxOdometer) {
        maxOdometer = maxOffline;
      }

      if (odometer < maxOdometer) {
        _showErrorMessage(
            'O odômetro informado não pode ser menor que o último registrado ($maxOdometer km)');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;

      if (!isOnline) {
        await LocalDatabaseService().insertAbastecimentoOffline({
          'vehicleId': widget.vehicleId,
          'journeyId': _journeyId!,
          'supplierId': selectedSupplier!.id,
          'liters': liters,
          'odometer': odometer,
          'dateTime': DateTime.now().toIso8601String(),
        });

        // Atualizar odômetro local após abastecimento offline
        await _updateLocalOdometer(odometer);

        if (!mounted) return;
        Navigator.pop(context, true);
        _showSuccessMessage('Abastecimento registrado offline',
            color: AppTheme.warningColor);
        return;
      }

      final result = await _fuelService.registerFuelRefill(
        journeyId: _journeyId!,
        vehicleId: widget.vehicleId,
        driverId: '0',
        gasStation: selectedSupplier!.id,
        liters: liters,
        odometerReading: odometer,
      );

      if (!mounted) return;

      // Atualizar odômetro local após abastecimento online
      await _updateLocalOdometer(odometer);

      Navigator.pop(context, true);
      await _fuelService.addLitersToJourneyTotal(_journeyId!, liters);
      _showSuccessMessage('Abastecimento registrado com sucesso!');
    } catch (e) {
      setState(() {
        _isSubmitting = false;

        String errorMsg = e.toString();

        if (errorMsg.contains("odômetro informado") &&
            errorMsg.contains("não pode ser menor")) {
          try {
            errorMsg = errorMsg.replaceAll('Exception: ', '');
            errorMsg = errorMsg.replaceAll('"', '');
          } catch (_) {}
          _errorMessage = errorMsg;
        } else if (errorMsg.contains("selecionar um posto")) {
          _errorMessage = "É necessário selecionar um posto de combustível";
          _highlightSupplier = true;
        } else if (errorMsg.contains("200") || errorMsg.contains("success")) {
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

  // Método para atualizar o odômetro local
  Future<void> _updateLocalOdometer(int newOdometer) async {
    try {
      final vehicleProvider =
          Provider.of<VehicleProvider>(context, listen: false);

      // Atualizar o odômetro no provider
      await vehicleProvider.updateOdometer(newOdometer);

      // Atualizar o estado local
      setState(() {
        _currentOdometer = newOdometer;
      });

      print('Odômetro atualizado localmente para: $newOdometer km');
    } catch (e) {
      print('Erro ao atualizar odômetro local: $e');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showSuccessMessage(String message,
      {Color color = AppTheme.successColor}) {
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
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.backgroundGradientDark
              : AppTheme.backgroundGradientLight,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppTheme.spacing16,
                left: AppTheme.spacing24,
                right: AppTheme.spacing24,
                bottom: AppTheme.spacing20,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkCard.withOpacity(0.8)
                            : AppTheme.lightCard.withOpacity(0.8),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.darkBorder
                              : AppTheme.lightBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Text(
                    'Registrar Abastecimento',
                    style: AppTheme.headlineMedium.copyWith(
                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: RefreshIndicator(
                  onRefresh: _loadSuppliers,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campo Odômetro
                        _buildFieldSection(
                          title: 'Leitura do Odômetro',
                          child: _buildTextField(
                            controller: odometerController,
                            hintText: 'Atual: $_currentOdometer km',
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            isDark: isDark,
                          ),
                          isDark: isDark,
                        ),

                        const SizedBox(height: AppTheme.spacing24),

                        // Campo Litros
                        _buildFieldSection(
                          title: 'Litros Abastecidos',
                          child: _buildTextField(
                            controller: litersController,
                            hintText: 'Informe a quantidade em litros',
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: () {
                              FocusScope.of(context).unfocus();
                            },
                            isDark: isDark,
                          ),
                          isDark: isDark,
                        ),

                        const SizedBox(height: AppTheme.spacing24),

                        // Campo Posto
                        _buildFieldSection(
                          title: 'Selecione o Posto',
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildSupplierDropdown(isDark),
                              ),
                              const SizedBox(width: AppTheme.spacing12),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.darkCard
                                      : AppTheme.lightCard,
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMedium),
                                  border: Border.all(
                                    color: isDark
                                        ? AppTheme.darkBorder
                                        : AppTheme.lightBorder,
                                    width: 0.5,
                                  ),
                                ),
                                child: IconButton(
                                  tooltip: 'Sincronizar fornecedores',
                                  onPressed: _isSyncingSuppliers
                                      ? null
                                      : _syncSuppliers,
                                  icon: _isSyncingSuppliers
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppTheme.primaryColor),
                                          ),
                                        )
                                      : Icon(
                                          Icons.sync_rounded,
                                          color: AppTheme.primaryColor,
                                          size: 20,
                                        ),
                                ),
                              ),
                            ],
                          ),
                          isDark: isDark,
                        ),

                        const SizedBox(height: AppTheme.spacing48),

                        // Botão de registro
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: AppTheme.actionButton(
                            onPressed: (!_isLoading &&
                                    !_isSubmitting &&
                                    selectedSupplier != null &&
                                    odometerController.text.isNotEmpty &&
                                    litersController.text.isNotEmpty)
                                ? _registrarAbastecimento
                                : () {},
                            isPrimary: true,
                            isDark: isDark,
                            child: _isSubmitting
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Registrar Abastecimento',
                                    style: AppTheme.titleMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
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

  Widget _buildFieldSection({
    required String title,
    required Widget child,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            color: isDark ? AppTheme.darkText : AppTheme.lightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacing8),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    VoidCallback? onFieldSubmitted,
  }) {
    return AppTheme.modernCard(
      isDark: isDark,
      padding: EdgeInsets.zero,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted:
            onFieldSubmitted != null ? (_) => onFieldSubmitted() : null,
        style: AppTheme.bodyLarge.copyWith(
          color: isDark ? AppTheme.darkText : AppTheme.lightText,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTheme.bodyLarge.copyWith(
            color: isDark
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing20,
            vertical: AppTheme.spacing16,
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierDropdown(bool isDark) {
    return AppTheme.modernCard(
      isDark: isDark,
      padding: EdgeInsets.zero,
      backgroundColor:
          _highlightSupplier ? AppTheme.errorColor.withOpacity(0.1) : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: _highlightSupplier
              ? Border.all(color: AppTheme.errorColor, width: 1)
              : null,
        ),
        child: _isLoading
            ? Container(
                height: 56,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                ),
              )
            : _errorMessage != null
                ? Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing20),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppTheme.errorColor, size: 20),
                        const SizedBox(width: AppTheme.spacing8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTheme.bodyMedium
                                .copyWith(color: AppTheme.errorColor),
                          ),
                        ),
                        TextButton(
                          onPressed: _loadSuppliers,
                          child: Text(
                            'Tentar novamente',
                            style: AppTheme.bodySmall
                                .copyWith(color: AppTheme.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<Supplier>(
                      value: _suppliers.contains(selectedSupplier)
                          ? selectedSupplier
                          : null,
                      hint: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing20),
                        child: Text(
                          'Selecionar Posto',
                          style: AppTheme.bodyLarge.copyWith(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary,
                          ),
                        ),
                      ),
                      isExpanded: true,
                      icon: Padding(
                        padding:
                            const EdgeInsets.only(right: AppTheme.spacing20),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      dropdownColor:
                          isDark ? AppTheme.darkCard : AppTheme.lightCard,
                      style: AppTheme.bodyLarge.copyWith(
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      ),
                      items: _suppliers.isEmpty
                          ? [
                              DropdownMenuItem<Supplier>(
                                value: null,
                                enabled: false,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacing20),
                                  child: Text(
                                    'Nenhum fornecedor disponível',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: isDark
                                          ? AppTheme.darkTextSecondary
                                          : AppTheme.lightTextSecondary,
                                    ),
                                  ),
                                ),
                              )
                            ]
                          : _suppliers.map((Supplier supplier) {
                              return DropdownMenuItem<Supplier>(
                                value: supplier,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacing20),
                                  child: Text(
                                    supplier.name,
                                    style: AppTheme.bodyLarge.copyWith(
                                      color: isDark
                                          ? AppTheme.darkText
                                          : AppTheme.lightText,
                                    ),
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
    );
  }
}
