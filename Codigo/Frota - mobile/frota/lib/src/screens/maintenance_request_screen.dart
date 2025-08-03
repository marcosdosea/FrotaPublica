import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/maintenance_provider.dart';
import '../utils/app_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/local_database_service.dart';

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

class _MaintenanceRequestScreenState extends State<MaintenanceRequestScreen>
    with TickerProviderStateMixin {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  String _selectedPriority = 'Média';
  String _selectedCategory = 'Mecânica';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _priorities = ['Baixa', 'Média', 'Alta', 'Urgente'];
  final List<String> _categories = [
    'Mecânica',
    'Elétrica',
    'Pneus',
    'Carroceria',
    'Interior',
    'Outros'
  ];

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
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, descreva o problema'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;

      if (!isOnline) {
        await LocalDatabaseService().insertManutencaoOffline({
          'vehicleId': widget.vehicleId,
          'description': _descriptionController.text.trim(),
          'priority': _selectedPriority,
          'category': _selectedCategory,
          'dateTime': DateTime.now().toIso8601String(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solicitação registrada offline'),
              backgroundColor: AppTheme.warningColor,
            ),
          );
          Navigator.pop(context);
        }
        return;
      }

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
              backgroundColor: AppTheme.successColor,
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
              backgroundColor: AppTheme.errorColor,
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
                    'Solicitação de Manutenção',
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
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ícone e descrição
                        AppTheme.modernCard(
                          isDark: isDark,
                          padding: const EdgeInsets.all(AppTheme.spacing24),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.warningColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusXLarge),
                                ),
                                child: const Icon(
                                  Icons.build_rounded,
                                  size: 40,
                                  color: AppTheme.warningColor,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing16),
                              Text(
                                'Solicitação de Manutenção',
                                style: AppTheme.headlineMedium.copyWith(
                                  color: isDark
                                      ? AppTheme.darkText
                                      : AppTheme.lightText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppTheme.spacing8),
                              Text(
                                'Descreva detalhadamente o problema encontrado no veículo',
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

                        // Categoria
                        _buildFieldSection(
                          title: 'Categoria',
                          child: _buildCategorySelector(isDark),
                          isDark: isDark,
                        ),

                        const SizedBox(height: AppTheme.spacing24),

                        // Prioridade
                        _buildFieldSection(
                          title: 'Prioridade',
                          child: _buildPrioritySelector(isDark),
                          isDark: isDark,
                        ),

                        const SizedBox(height: AppTheme.spacing24),

                        // Descrição do problema
                        _buildFieldSection(
                          title: 'Descrição do Problema',
                          child: AppTheme.modernCard(
                            isDark: isDark,
                            padding: EdgeInsets.zero,
                            child: TextField(
                              controller: _descriptionController,
                              maxLines: 6,
                              style: AppTheme.bodyLarge.copyWith(
                                color: isDark
                                    ? AppTheme.darkText
                                    : AppTheme.lightText,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Descreva detalhadamente o problema encontrado...',
                                hintStyle: AppTheme.bodyMedium.copyWith(
                                  color: isDark
                                      ? AppTheme.darkTextSecondary
                                      : AppTheme.lightTextSecondary,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusLarge),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusLarge),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusLarge),
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
                          isDark: isDark,
                        ),

                        const SizedBox(height: AppTheme.spacing48),

                        // Botão de envio
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: AppTheme.actionButton(
                            onPressed: _isSubmitting ? () {} : _submitRequest,
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
                                    'Enviar Solicitação',
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

  Widget _buildCategorySelector(bool isDark) {
    return Wrap(
      spacing: AppTheme.spacing8,
      runSpacing: AppTheme.spacing8,
      children: _categories.map((category) {
        final isSelected = _selectedCategory == category;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor
                  : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                width: 0.5,
              ),
            ),
            child: Text(
              category,
              style: AppTheme.bodyMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppTheme.darkText : AppTheme.lightText),
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrioritySelector(bool isDark) {
    return Row(
      children: _priorities.map((priority) {
        final isSelected = _selectedPriority == priority;
        Color priorityColor;
        switch (priority) {
          case 'Baixa':
            priorityColor = AppTheme.successColor;
            break;
          case 'Média':
            priorityColor = AppTheme.infoColor;
            break;
          case 'Alta':
            priorityColor = AppTheme.warningColor;
            break;
          case 'Urgente':
            priorityColor = AppTheme.errorColor;
            break;
          default:
            priorityColor = AppTheme.primaryColor;
        }

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: priority != _priorities.last ? AppTheme.spacing8 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPriority = priority;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? priorityColor.withOpacity(0.1)
                      : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: isSelected
                        ? priorityColor
                        : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Text(
                  priority,
                  style: AppTheme.bodySmall.copyWith(
                    color: isSelected
                        ? priorityColor
                        : (isDark ? AppTheme.darkText : AppTheme.lightText),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
