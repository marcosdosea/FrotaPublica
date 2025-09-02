import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';
import '../utils/app_theme.dart';
import '../screens/offline_sync_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _biometricEnabled = false;
  bool _isLoadingBiometric = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeBiometricState();
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
      curve: Curves.easeInOut,
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

  Future<void> _initializeBiometricState() async {
    try {
      final enabled = await BiometricService.isBiometricEnabled();
      if (mounted) {
        setState(() {
          _biometricEnabled = enabled;
        });
      }
    } catch (e) {
      print('Erro ao inicializar estado da biometria: $e');
    }
  }

  Future<void> _onBiometricToggleChanged(bool value) async {
    if (_isLoadingBiometric) return;

    setState(() {
      _isLoadingBiometric = true;
    });

    try {
      if (value) {
        final success = await BiometricService.setupBiometric();
        if (success && mounted) {
          setState(() {
            _biometricEnabled = true;
          });

          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.currentUser != null) {
            final savedCredentials =
                await SecureStorageService.getSavedCredentials();
            if (savedCredentials['username'] != null &&
                savedCredentials['password'] != null) {
              await BiometricService.saveCredentials(
                savedCredentials['username']!,
                savedCredentials['password']!,
              );
            }
          }
        } else if (mounted) {
          final isAvailable = await BiometricService.isBiometricAvailable();
          if (!isAvailable) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Biometria não disponível. Verifique se há biometrias cadastradas no dispositivo e se o app tem permissão.'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Não foi possível ativar a biometria. Tente novamente.'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        }
      } else {
        await BiometricService.setBiometricEnabled(false);
        await BiometricService.clearSavedCredentials();

        if (mounted) {
          setState(() {
            _biometricEnabled = false;
          });
        }
      }
    } catch (e) {
      print('Erro ao alterar configuração de biometria: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao configurar biometria: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBiometric = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));

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
                    'Perfil',
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
                      children: [
                        // Card do perfil do usuário
                        _buildUserProfileCard(isDark),
                        const SizedBox(height: AppTheme.spacing24),

                        // Card de configurações
                        _buildSettingsCard(isDark),
                        const SizedBox(height: AppTheme.spacing24),

                        // Card de informações do app
                        _buildAppInfoCard(isDark),
                        const SizedBox(height: AppTheme.spacing32),

                        // Botão de logout
                        _buildLogoutButton(isDark),
                        const SizedBox(height: AppTheme.spacing20),
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

  Widget _buildUserProfileCard(bool isDark) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return AppTheme.modernCard(
          isDark: isDark,
          padding: const EdgeInsets.all(AppTheme.spacing32),
          child: Column(
            children: [
              // Avatar com gradiente
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),

              // Nome do usuário
              Text(
                user?.name ?? 'Usuário',
                style: AppTheme.displayMedium.copyWith(
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing8),

              // CPF
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing16,
                  vertical: AppTheme.spacing8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  'CPF: ${user?.cpf ?? 'Não informado'}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Email (se disponível)
              if (user?.email != null) ...[
                const SizedBox(height: AppTheme.spacing16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_rounded,
                      size: 16,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary,
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Text(
                      user!.email!,
                      style: AppTheme.bodyMedium.copyWith(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsCard(bool isDark) {
    return AppTheme.modernCard(
      isDark: isDark,
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configurações',
            style: AppTheme.headlineMedium.copyWith(
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),
          // Toggle tema escuro
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return _buildSettingItem(
                icon: Icons.dark_mode_rounded,
                title: 'Tema escuro',
                subtitle: 'Ativar modo escuro',
                trailing: Switch.adaptive(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: AppTheme.primaryColor,
                ),
                isDark: isDark,
              );
            },
          ),

          const SizedBox(height: AppTheme.spacing16),

          // Toggle biometria
          _buildSettingItem(
            icon: Icons.fingerprint_rounded,
            title: 'Login com biometria',
            subtitle: 'Usar impressão digital ou Face ID',
            trailing: _isLoadingBiometric
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  )
                : Switch.adaptive(
                    value: _biometricEnabled,
                    onChanged: _onBiometricToggleChanged,
                    activeColor: AppTheme.primaryColor,
                  ),
            isDark: isDark,
          ),

          const SizedBox(height: AppTheme.spacing16),

          // Notificações
          _buildSettingItem(
            icon: Icons.notifications_rounded,
            title: 'Notificações',
            subtitle: 'Gerenciar notificações',
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
            onTap: () {
              // Implementar navegação para configurações de notificação
            },
            isDark: isDark,
          ),

          const SizedBox(height: AppTheme.spacing16),

          // Privacidade
          _buildSettingItem(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacidade',
            subtitle: 'Configurações de privacidade',
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
            onTap: () {
              // Implementar navegação para configurações de privacidade
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.titleMedium.copyWith(
                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(bool isDark) {
    return AppTheme.modernCard(
      isDark: isDark,
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sobre o App',
            style: AppTheme.headlineMedium.copyWith(
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),
          _buildInfoItem(
            icon: Icons.info_rounded,
            title: 'Versão',
            value: '1.0.0',
            isDark: isDark,
          ),
          const SizedBox(height: AppTheme.spacing16),
          _buildInfoItem(
            icon: Icons.description_rounded,
            title: 'Termos de Uso',
            value: 'Políticas e termos',
            onTap: () {
              // Implementar navegação para termos
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.titleMedium.copyWith(
                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    value,
                    style: AppTheme.bodySmall.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: AppTheme.actionButton(
            onPressed: authProvider.isLoading
                ? () {}
                : () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor:
                            isDark ? AppTheme.darkCard : AppTheme.lightCard,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLarge),
                        ),
                        title: Text(
                          'Confirmar Logout',
                          style: AppTheme.headlineMedium.copyWith(
                            color:
                                isDark ? AppTheme.darkText : AppTheme.lightText,
                          ),
                        ),
                        content: Text(
                          'Tem certeza que deseja sair da sua conta?',
                          style: AppTheme.bodyLarge.copyWith(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              'Cancelar',
                              style: AppTheme.bodyMedium.copyWith(
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'Sair',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true) {
                      await authProvider.logout();
                      if (mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/presentation',
                          (route) => false,
                        );
                      }
                    }
                  },
            isDestructive: true,
            isDark: isDark,
            child: authProvider.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        'Sair da Conta',
                        style: AppTheme.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
