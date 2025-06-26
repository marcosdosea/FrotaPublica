import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/auth_provider.dart';
import '../providers/journey_provider.dart';
import '../providers/vehicle_provider.dart';
import '../screens/driver_home_screen.dart';
import '../services/biometric_service.dart';
import '../utils/formatters.dart';
import '../widgets/keyboard_aware_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _biometricEnabled = false;
  bool _biometricSupported = false;

  @override
  void initState() {
    super.initState();
    _initializeLogin();
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _passwordController.dispose();
    super.dispose();
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

        if (authProvider.lastLoggedCpf != null) {
          _cpfController.text = authProvider.lastLoggedCpf!;
        }

        if (_biometricEnabled && !authProvider.isAuthenticated) {
          _tryBiometricLogin();
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction,
    VoidCallback? onFieldSubmitted,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted != null ? (_) => onFieldSubmitted() : null,
        validator: validator,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey.shade500,
            fontWeight: FontWeight.w400,
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: isDark 
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF116AD5),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
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
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark 
            ? const Color(0xFF0F0F23)
            : const Color(0xFFE3F2FD),
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        height: screenHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F0F23),
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    const Color(0xFFE3F2FD),
                    const Color(0xFFBBDEFB),
                    const Color(0xFF90CAF9),
                  ],
          ),
        ),
        child: SafeArea(
          child: KeyboardAwareWidget(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Logo simples
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF116AD5).withOpacity(0.1),
                          border: Border.all(
                            color: const Color(0xFF116AD5).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/img/logo.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Título
                      Text(
                        'Bem vindo!',
                        style: TextStyle(
                          fontSize: 36,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF116AD5),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtítulo
                      Text(
                        'Faça login para continuar',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Campo CPF
                      _buildModernTextField(
                        controller: _cpfController,
                        hintText: 'CPF',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [CpfInputFormatter()],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe seu CPF';
                          }
                          final cpfRegex = RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$');
                          if (!cpfRegex.hasMatch(value)) {
                            return 'Digite um CPF válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Campo Senha
                      _buildModernTextField(
                        controller: _passwordController,
                        hintText: 'Senha',
                        obscureText: _obscureText,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: () {
                          FocusScope.of(context).unfocus();
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: isDark 
                                ? Colors.white.withOpacity(0.6)
                                : Colors.grey.shade600,
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
                      ),

                      // Mensagem de erro
                      if (authProvider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authProvider.error!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Link "Esqueci a senha"
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Esqueci a senha',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF116AD5),
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFF116AD5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Botão de login
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF116AD5),
                              Color(0xFF0066CC),
                              Color(0xFF004BA7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF116AD5).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: authProvider.isLoading ? null : _login,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Entrar',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Seção biometria
                      if (_biometricSupported && _biometricEnabled) ...[
                        const SizedBox(height: 30),
                        
                        // Divisor "ou"
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: isDark 
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'ou',
                                style: TextStyle(
                                  color: isDark 
                                      ? Colors.white.withOpacity(0.6)
                                      : Colors.grey.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: isDark 
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Botão biometria
                        GestureDetector(
                          onTap: authProvider.isLoading ? null : _tryBiometricLogin,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF116AD5).withOpacity(0.1),
                              border: Border.all(
                                color: const Color(0xFF116AD5).withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.fingerprint_rounded,
                              size: 36,
                              color: Color(0xFF116AD5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        Text(
                          'Usar biometria',
                          style: TextStyle(
                            color: const Color(0xFF116AD5),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
