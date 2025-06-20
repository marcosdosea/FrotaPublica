import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/auth_provider.dart';
import '../providers/journey_provider.dart';
import '../providers/vehicle_provider.dart';
import '../screens/driver_home_screen.dart';
import '../services/biometric_service.dart';
import '../utils/formatters.dart';

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

  Future<void> _initializeLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Verificar suporte à biometria
    final supported = await BiometricService.isDeviceSupported();
    final canCheck = await BiometricService.canCheckBiometrics();
    final enabled = await BiometricService.isBiometricEnabled();

    setState(() {
      _biometricSupported = supported && canCheck;
      _biometricEnabled = enabled;
    });

    // Pré-preencher CPF se disponível
    if (authProvider.lastLoggedCpf != null) {
      _cpfController.text = authProvider.lastLoggedCpf!;
    }

    // Se a biometria estiver habilitada e o usuário não estiver autenticado,
    // tentar login automático com biometria
    if (_biometricEnabled && !authProvider.isAuthenticated) {
      _tryBiometricLogin();
    }
  }

  Future<void> _tryBiometricLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.loginWithBiometrics();

    if (success && mounted) {
      _navigateAfterLogin(authProvider);
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _cpfController.text,
        _passwordController.text,
        saveBiometric: _biometricEnabled,
      );

      if (success && mounted) {
        _navigateAfterLogin(authProvider);
      }
    }
  }

  Future<void> _navigateAfterLogin(AuthProvider authProvider) async {
    // Verificar se o usuário tem um percurso ativo
    final journeyProvider = Provider.of<JourneyProvider>(context, listen: false);
    await journeyProvider.loadActiveJourney(authProvider.currentUser!.id);

    if (journeyProvider.hasActiveJourney && journeyProvider.activeJourney != null) {
      // Se há jornada ativa, obter o veículo associado
      final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
      final vehicle = await vehicleProvider.getVehicleById(journeyProvider.activeJourney!.vehicleId);

      if (vehicle != null && mounted) {
        // Navegar para a tela de motorista com o veículo
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DriverHomeScreen(vehicle: vehicle),
          ),
        );
        return;
      }
    }

    // Se não há jornada ativa ou não foi possível recuperar o veículo,
    // redirecionar para tela de veículos disponíveis
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/available_vehicles');
    }
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                    'assets/img/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                // Welcome text
                const Text(
                  'Bem vindo!',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 40),

                // CPF field
                TextFormField(
                  controller: _cpfController,
                  decoration: const InputDecoration(
                    hintText: 'CPF',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    CpfInputFormatter(),
                  ],
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
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: 'Senha',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe sua senha';
                    }
                    return null;
                  },
                ),

                // Error message
                if (authProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      authProvider.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Esqueci a senha',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0066CC),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login button
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF116AD5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
                              fontSize: 20,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),

                // Biometric login button (only show if supported and enabled)
                if (_biometricSupported && _biometricEnabled) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'ou',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: authProvider.isLoading ? null : _tryBiometricLogin,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF116AD5).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF116AD5),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.fingerprint,
                        size: 30,
                        color: Color(0xFF116AD5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Usar biometria',
                    style: TextStyle(
                      color: Color(0xFF116AD5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
