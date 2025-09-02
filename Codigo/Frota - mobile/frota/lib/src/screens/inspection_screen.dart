import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/inspection_service.dart';
import '../providers/journey_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
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

class _InspectionScreenState extends State<InspectionScreen>
    with TickerProviderStateMixin {
  final TextEditingController problemsController = TextEditingController();
  final InspectionService _inspectionService = InspectionService();
  bool _isSubmitting = false;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;

      if (!isOnline && widget.type == 'S') {
        await LocalDatabaseService().insertVistoriaSaidaOffline({
          'vehicleId': widget.vehicleId,
          'journeyId': Provider.of<JourneyProvider>(context, listen: false)
                  .activeJourney
                  ?.id ??
              '',
          'inspectionData': problemsController.text.trim(),
          'dateTime': DateTime.now().toIso8601String(),
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('inspection_departure_${widget.vehicleId}', true);
        if (!mounted) return;
        Navigator.pop(context, true);
        _showSuccessMessage('Vistoria registrada offline',
            color: AppTheme.warningColor);
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
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTheme.headlineMedium.copyWith(
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ícone e descrição da vistoria
                        AppTheme.modernCard(
                          isDark: isDark,
                          padding: const EdgeInsets.all(AppTheme.spacing24),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusXLarge),
                                ),
                                child: const Icon(
                                  Icons.checklist_rounded,
                                  size: 40,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing16),
                              Text(
                                widget.type == 'S'
                                    ? 'Vistoria de Saída'
                                    : 'Vistoria de Retorno',
                                style: AppTheme.headlineMedium.copyWith(
                                  color: isDark
                                      ? AppTheme.darkText
                                      : AppTheme.lightText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppTheme.spacing8),
                              Text(
                                widget.type == 'S'
                                    ? 'Verifique o estado do veículo antes de iniciar o percurso'
                                    : 'Verifique o estado do veículo ao finalizar o percurso',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: isDark
                                      ? AppTheme.darkTextSecondary
                                      : AppTheme.lightTextSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacing32),

                        // Campo de problemas
                        Text(
                          'Problemas Identificados',
                          style: AppTheme.titleMedium.copyWith(
                            color:
                                isDark ? AppTheme.darkText : AppTheme.lightText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          'Descreva detalhadamente qualquer problema encontrado ou escreva "Nenhum" caso não haja problemas.',
                          style: AppTheme.bodySmall.copyWith(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing16),

                        AppTheme.modernCard(
                          isDark: isDark,
                          padding: EdgeInsets.zero,
                          child: TextField(
                            controller: problemsController,
                            maxLines: 6,
                            style: AppTheme.bodyLarge.copyWith(
                              color: isDark
                                  ? AppTheme.darkText
                                  : AppTheme.lightText,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Ex: Pneu dianteiro direito com baixa pressão, farol esquerdo queimado...',
                              hintStyle: AppTheme.bodyMedium.copyWith(
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.lightTextSecondary,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusLarge),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusLarge),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusLarge),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding:
                                  const EdgeInsets.all(AppTheme.spacing20),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacing32),

                        // Checklist rápido
                        AppTheme.modernCard(
                          isDark: isDark,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.all(AppTheme.spacing8),
                                    decoration: BoxDecoration(
                                      color:
                                          AppTheme.infoColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.radiusSmall),
                                    ),
                                    child: const Icon(
                                      Icons.info_outline_rounded,
                                      color: AppTheme.infoColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacing12),
                                  Text(
                                    'Itens para Verificar',
                                    style: AppTheme.titleMedium.copyWith(
                                      color: isDark
                                          ? AppTheme.darkText
                                          : AppTheme.lightText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacing16),
                              ..._buildChecklistItems(isDark),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacing48),

                        // Botão de registro
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: AppTheme.actionButton(
                            onPressed:
                                _isSubmitting ? () {} : _registerInspection,
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
                                    'Registrar Vistoria',
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

  List<Widget> _buildChecklistItems(bool isDark) {
    final items = [
      'Pneus e pressão',
      'Luzes e sinalização',
      'Espelhos retrovisores',
      'Limpadores de para-brisa',
      'Níveis de fluidos',
      'Documentação do veículo',
    ];

    return items
        .map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Text(
                    item,
                    style: AppTheme.bodyMedium.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }
}
