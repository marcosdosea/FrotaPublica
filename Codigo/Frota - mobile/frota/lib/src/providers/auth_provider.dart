import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../utils/api_client.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  String? _lastLoggedCpf;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  String? get lastLoggedCpf => _lastLoggedCpf;

  // Inicializar - verificar se há um usuário logado
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('AuthProvider: Inicializando e verificando usuário atual');

      // Configurar callbacks do ApiClient
      _setupApiClientCallbacks();

      _currentUser = await _authService.getCurrentUser();
      _error = null;

      if (_currentUser != null) {
        print('AuthProvider: Usuário autenticado na inicialização: ${_currentUser!.name}');
        // Carregar o último CPF usado
        final credentials = await BiometricService.getSavedCredentials();
        _lastLoggedCpf = credentials['cpf'];
      } else {
        print('AuthProvider: Nenhum usuário autenticado na inicialização');
        // Ainda assim, carregar o último CPF para facilitar o login
        final credentials = await BiometricService.getSavedCredentials();
        _lastLoggedCpf = credentials['cpf'];
      }
    } catch (e) {
      print('AuthProvider: Erro na inicialização: $e');
      _error = 'Erro ao carregar usuário';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Configurar callbacks do ApiClient para manter sincronização
  void _setupApiClientCallbacks() {
    ApiClient.onTokenUpdated = (token, refreshToken, expiry) {
      print('AuthProvider: Token atualizado pelo ApiClient');
      notifyListeners();
    };

    ApiClient.onTokenExpired = () {
      print('AuthProvider: Token expirou e não pôde ser renovado');
      _handleTokenExpiration();
    };
  }

  // Método para lidar com expiração de token
  void _handleTokenExpiration() async {
    print('AuthProvider: Lidando com expiração de token');
    _currentUser = null;
    _error = 'Sessão expirada. Faça login novamente.';
    notifyListeners();
  }

  // Login com biometria
  Future<bool> loginWithBiometrics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('AuthProvider: Tentando login com biometria');
      
      // Verificar se a biometria está habilitada
      final biometricEnabled = await BiometricService.isBiometricEnabled();
      if (!biometricEnabled) {
        _error = 'Biometria não está habilitada';
        return false;
      }

      // Autenticar com biometria
      final authenticated = await BiometricService.authenticateWithBiometrics();
      if (!authenticated) {
        _error = 'Falha na autenticação biométrica';
        return false;
      }

      // Obter credenciais salvas
      final credentials = await BiometricService.getSavedCredentials();
      final cpf = credentials['cpf'];
      final password = credentials['password'];

      if (cpf == null || password == null) {
        _error = 'Credenciais não encontradas';
        return false;
      }

      // Fazer login com as credenciais salvas
      _currentUser = await _authService.login(cpf, password);
      final success = _currentUser != null;

      if (success) {
        print('AuthProvider: Login biométrico bem-sucedido para: ${_currentUser!.name}');
        _lastLoggedCpf = cpf;
        _error = null;
      } else {
        print('AuthProvider: Login biométrico falhou');
        _error = 'Falha no login. Verifique suas credenciais.';
      }

      return success;
    } catch (e) {
      print('AuthProvider: Erro durante login biométrico: $e');
      _error = 'Erro ao fazer login com biometria: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login tradicional
  Future<bool> login(String cpf, String password, {bool saveBiometric = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('AuthProvider: Tentando login com CPF: $cpf');
      _currentUser = await _authService.login(cpf, password);
      final success = _currentUser != null;

      if (success) {
        print('AuthProvider: Login bem-sucedido para: ${_currentUser!.name}');
        _lastLoggedCpf = cpf;
        _error = null;

        // Salvar credenciais se a biometria estiver habilitada
        if (saveBiometric && await BiometricService.isBiometricEnabled()) {
          await BiometricService.saveCredentials(cpf, password);
        }
      } else {
        print('AuthProvider: Login falhou - credenciais inválidas');
        _error = 'CPF ou senha incorretos';
      }

      return success;
    } catch (e) {
      print('AuthProvider: Erro durante login: $e');
      _error = 'Erro ao fazer login: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh Token - agora usa o método do ApiClient
  Future<bool> refreshToken() async {
    try {
      print('AuthProvider: Tentando renovar token...');

      final success = await ApiClient.refreshToken();

      if (success) {
        print('AuthProvider: Token renovado com sucesso');
        _error = null;
      } else {
        print('AuthProvider: Falha ao renovar token');
        _error = 'Falha ao renovar sessão';
        _currentUser = null;
        notifyListeners();
      }

      return success;
    } catch (e) {
      print('AuthProvider: Erro ao renovar token: $e');
      _error = 'Erro ao renovar sessão: $e';
      _currentUser = null;
      notifyListeners();
      return false;
    }
  }

  // Verificar se o token ainda é válido
  Future<bool> isTokenValid() async {
    try {
      final isExpired = await ApiClient.isTokenExpired();
      return !isExpired;
    } catch (e) {
      print('AuthProvider: Erro ao verificar validade do token: $e');
      return false;
    }
  }

  // Método para verificar autenticação de forma mais robusta
  Future<bool> checkAuthenticationStatus() async {
    if (_currentUser == null) {
      return false;
    }

    // Verificar se o token ainda é válido
    final tokenValid = await isTokenValid();
    if (!tokenValid) {
      print('AuthProvider: Token inválido, tentando renovar...');
      final renewed = await refreshToken();
      if (!renewed) {
        print('AuthProvider: Não foi possível renovar token, fazendo logout');
        await logout();
        return false;
      }
    }

    return true;
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('AuthProvider: Realizando logout');
      await _authService.logout();
      _currentUser = null;
      _error = null;
      // Manter o último CPF para facilitar próximo login
      print('AuthProvider: Logout concluído com sucesso');
    } catch (e) {
      print('AuthProvider: Erro durante logout: $e');
      _error = 'Erro ao fazer logout';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
