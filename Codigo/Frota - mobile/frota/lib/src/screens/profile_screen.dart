import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/biometric_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _biometricEnabled = false;
  bool _biometricSupported = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometricSupport();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final supported = await BiometricService.isDeviceSupported();
      final canCheck = await BiometricService.canCheckBiometrics();
      final enabled = await BiometricService.isBiometricEnabled();

      if (mounted) {
        setState(() {
          _biometricSupported = supported && canCheck;
          _biometricEnabled = enabled;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _biometricSupported = false;
          _biometricEnabled = false;
        });
      }
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (value) {
        final success = await BiometricService.setupBiometric();
        if (success) {
          if (mounted) {
            setState(() {
              _biometricEnabled = true;
            });
            _showSnackBar('Biometria habilitada com sucesso!', Colors.green);
          }
        } else {
          if (mounted) {
            _showSnackBar('Falha ao habilitar biometria', Colors.red);
          }
        }
      } else {
        await BiometricService.setBiometricEnabled(false);
        await BiometricService.clearSavedCredentials();
        if (mounted) {
          setState(() {
            _biometricEnabled = false;
          });
          _showSnackBar('Biometria desabilitada', Colors.orange);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao alterar configuração de biometria', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao fazer logout', Colors.red);
      }
    }
  }

  Widget _buildInfoField(String value, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A5C) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0066CC),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        final user = authProvider.currentUser;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header com gradiente azul
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 30),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF116AD5),
                        Color(0xFF116AD5),
                        Color(0xFF004BA7),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x29000000),
                        offset: Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header com título e botão voltar
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Perfil',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Informações do usuário
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Nome do Usuário',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Motorista',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Conteúdo principal
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Seção Informações Pessoais
                          _buildSectionTitle('Informações Pessoais'),
                          const SizedBox(height: 16),

                          // Campo CPF
                          _buildInfoField(user?.cpf ?? 'CPF não informado', isDark),
                          const SizedBox(height: 16),

                          // Campo Email
                          _buildInfoField(user?.email ?? 'Email não informado', isDark),
                          const SizedBox(height: 32),

                          // Seção Preferências
                          _buildSectionTitle('Preferências'),
                          const SizedBox(height: 16),

                          // Toggle Tema Escuro
                          Row(
                            children: [
                              Text(
                                'Tema escuro',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: themeProvider.themeMode == ThemeMode.dark,
                                onChanged: (value) {
                                  themeProvider.setThemeMode(
                                    value ? ThemeMode.dark : ThemeMode.light,
                                  );
                                },
                                activeColor: const Color(0xFF0066CC),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Toggle Biometria (apenas se suportado)
                          if (_biometricSupported) ...[
                            Row(
                              children: [
                                Text(
                                  'Usar biometria',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Switch(
                                  value: _biometricEnabled,
                                  onChanged: _isLoading ? null : _toggleBiometric,
                                  activeColor: const Color(0xFF0066CC),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Use sua impressão digital ou reconhecimento facial para fazer login',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],

                          const SizedBox(height: 80),

                          // Botão de Logout
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _handleLogout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Sair',
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
      },
    );
  }
}