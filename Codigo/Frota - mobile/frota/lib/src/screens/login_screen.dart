import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/auth_provider.dart';
import '../providers/journey_provider.dart';
import '../providers/vehicle_provider.dart';
import '../screens/driver_home_screen.dart';
import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';
import '../utils/formatters.dart';
import '../utils/app_theme.dart';
import '../widgets/keyboard_aware_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _obscureText = true;
  bool _rememberMe = false;
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _biometricEnabled = false;
  bool _biometricSupported = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLogin();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _cpfController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _formatCpf(String cpf) {
    final digitsOnly = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length != 11) return cpf;
    return '${digitsOnly.substring(0, 3)}.${digitsOnly.substring(3, 6)}.${digitsOnly.substring(6, 9)}-${digitsOnly.substring(9, 11)}';
  }

  Future<void> _initializeLogin() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final supported = await BiometricService.isDeviceSupported();
      final canCheck = await BiometricService.canCheckBiometrics();
      final enabled = await BiometricService.isBiometricEnabled();

      if (mounted) {
        setState(() {
          _biometricSupported = supported && canCheck;
          _biometricEnabled = enabled;
        });

        final savedCredentials =
            await SecureStorageService.getSavedCredentials();
        if (savedCredentials['username'] != null) {
          _cpfController.text = _formatCpf(savedCredentials['username']!);
          setState(() {
            _rememberMe = false;
          });
        } else if (authProvider.lastLoggedCpf != null) {
          _cpfController.text = _formatCpf(authProvider.lastLoggedCpf!);
        }
      }
    } catch (e) {
      print('Erro na inicialização do login: $e');
    }
  }

  Future<void> _tryBiometricLogin() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.loginWithBiometrics();

      if (success && mounted) {
        _navigateAfterLogin(authProvider);
      }
    } catch (e) {
      print('Erro no login biométrico: $e');
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.login(
          _cpfController.text,
          _passwordController.text,
          saveBiometric: _biometricEnabled,
          rememberMe: _rememberMe,
        );

        if (success && mounted) {
          _navigateAfterLogin(authProvider);
        }
      } catch (e) {
        print('Erro no login: $e');
      }
    }
  }

  Future<void> _navigateAfterLogin(AuthProvider authProvider) async {
    try {
      final journeyProvider =
          Provider.of<JourneyProvider>(context, listen: false);
      await journeyProvider.loadActiveJourney(authProvider.currentUser!.id);

      if (journeyProvider.hasActiveJourney &&
          journeyProvider.activeJourney != null) {
        final vehicleProvider =
            Provider.of<VehicleProvider>(context, listen: false);
        final vehicle = await vehicleProvider
            .getVehicleById(journeyProvider.activeJourney!.vehicleId);

        if (vehicle != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DriverHomeScreen(vehicle: vehicle),
            ),
          );
          return;
        }
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/available_vehicles');
      }
    } catch (e) {
      print('Erro na navegação após login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      extendBodyBehindAppBar: true,
      body: Container(
        height: screenHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.backgroundGradientDark
              : AppTheme.backgroundGradientLight,
        ),
        child: SafeArea(
          child: KeyboardAwareWidget(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spacing32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: AppTheme.spacing48),

                          // Logo
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusXLarge),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/icon/icon.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing48),

                          // Título
                          Text(
                            'Bem-vindo',
                            style: AppTheme.displayLarge.copyWith(
                              color: isDark
                                  ? AppTheme.darkText
                                  : AppTheme.lightText,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing8),

                          // Subtítulo
                          Text(
                            'Faça login para acessar sua conta',
                            style: AppTheme.bodyLarge.copyWith(
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spacing48),

                          // Campo CPF
                          _buildTextField(
                            controller: _cpfController,
                            hintText: 'CPF',
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [CpfInputFormatter()],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, informe seu CPF';
                              }
                              final cpfRegex =
                                  RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$');
                              if (!cpfRegex.hasMatch(value)) {
                                return 'Digite um CPF válido';
                              }
                              return null;
                            },
                            isDark: isDark,
                          ),
                          const SizedBox(height: AppTheme.spacing20),

                          // Campo Senha
                          _buildTextField(
                            controller: _passwordController,
                            hintText: 'Senha',
                            obscureText: _obscureText,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: () {
                              FocusScope.of(context).unfocus();
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.lightTextSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, informe sua senha';
                              }
                              return null;
                            },
                            isDark: isDark,
                          ),

                          // Checkbox "Lembrar senha"
                          Padding(
                            padding:
                                const EdgeInsets.only(top: AppTheme.spacing20),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor: AppTheme.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.radiusSmall),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacing12),
                                Expanded(
                                  child: Text(
                                    'Lembrar senha',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: isDark
                                          ? AppTheme.darkText
                                          : AppTheme.lightText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Mensagem de erro
                          if (authProvider.error != null)
                            Container(
                              margin: const EdgeInsets.only(
                                  top: AppTheme.spacing20),
                              padding: const EdgeInsets.all(AppTheme.spacing16),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium),
                                border: Border.all(
                                  color: AppTheme.errorColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppTheme.errorColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppTheme.spacing8),
                                  Expanded(
                                    child: Text(
                                      authProvider.error!,
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppTheme.errorColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: AppTheme.spacing32),

                          // Botão de login
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: AppTheme.actionButton(
                              onPressed:
                                  authProvider.isLoading ? () {} : _login,
                              isPrimary: true,
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
                                  : Text(
                                      'Entrar',
                                      style: AppTheme.titleMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          // Seção biometria
                          if (_biometricSupported && _biometricEnabled) ...[
                            const SizedBox(height: AppTheme.spacing40),

                            // Divisor "ou"
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: isDark
                                        ? AppTheme.darkBorder
                                        : AppTheme.lightBorder,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacing16),
                                  child: Text(
                                    'ou',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: isDark
                                          ? AppTheme.darkTextSecondary
                                          : AppTheme.lightTextSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: isDark
                                        ? AppTheme.darkBorder
                                        : AppTheme.lightBorder,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacing32),

                            // Botão biometria
                            GestureDetector(
                              onTap: authProvider.isLoading
                                  ? null
                                  : _tryBiometricLogin,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusXLarge),
                                  border: Border.all(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.fingerprint_rounded,
                                  size: 36,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing12),

                            Text(
                              'Usar biometria',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],

                          const SizedBox(height: AppTheme.spacing48),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction,
    VoidCallback? onFieldSubmitted,
  }) {
    return AppTheme.modernCard(
      isDark: isDark,
      padding: EdgeInsets.zero,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textInputAction: textInputAction,
        onFieldSubmitted:
            onFieldSubmitted != null ? (_) => onFieldSubmitted() : null,
        validator: validator,
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
          suffixIcon: suffixIcon,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            borderSide: const BorderSide(
              color: AppTheme.errorColor,
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing20,
            vertical: AppTheme.spacing20,
          ),
        ),
      ),
    );
  }
}
