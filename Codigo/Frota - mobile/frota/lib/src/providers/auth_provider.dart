import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'; // Added for WidgetsBinding
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';
import '../utils/api_client.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
    try {
      print('AuthProvider: Inicializando e verificando usuário atual');

      // Configurar callbacks do ApiClient
      _setupApiClientCallbacks();

      // Carregar credenciais salvas (tanto biometria quanto "lembrar senha")
      final biometricCredentials = await BiometricService.getSavedCredentials();
      final savedCredentials = await SecureStorageService.getSavedCredentials();

      // Priorizar credenciais salvas por "lembrar senha"
      if (savedCredentials['username'] != null) {
        _lastLoggedCpf = savedCredentials['username'];
      } else if (biometricCredentials['username'] != null) {
        _lastLoggedCpf = biometricCredentials['username'];
      }

      // Verificar se existe token válido
      final token = await ApiClient.getToken();
      final tokenValido = token != null && !(await ApiClient.isTokenExpired());

      // Buscar usuário salvo localmente
      _currentUser = await _authService.getCurrentUser();
      _error = null;

      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;

      if (_currentUser != null) {
        print(
            'AuthProvider: Usuário autenticado na inicialização: ${_currentUser!.name}');
      } else if (tokenValido) {
        print(
            'AuthProvider: Token válido, mas usuário não encontrado localmente.');
        if (isOnline) {
          final biometricEnabled = await BiometricService.isBiometricEnabled();
          if (biometricEnabled) {
            print(
                'AuthProvider: Tentando login biométrico automático na inicialização.');
            await loginWithBiometrics();
          } else if (savedCredentials['username'] != null &&
              savedCredentials['password'] != null) {
            print(
                'AuthProvider: Tentando login automático com credenciais salvas.');
            await login(
                savedCredentials['username']!, savedCredentials['password']!,
                rememberMe: true);
          } else {
            print(
                'AuthProvider: Biometria não ativada. Usuário deve fazer login manual.');
          }
        } else {
          if (savedCredentials['username'] != null) {
            print(
                'AuthProvider: Usuário offline, token válido e credenciais salvas. Permitindo acesso offline.');
            _currentUser = User(
              id: savedCredentials['username']!,
              name: savedCredentials['username']!,
              email: '',
              cpf: savedCredentials['username']!,
              role: 'Motorista',
              unidadeAdministrativaId: 1,
            );
            _error = null;
          } else {
            print(
                'AuthProvider: Usuário offline, token válido mas sem credenciais salvas.');
          }
        }
      } else {
        print(
            'AuthProvider: Nenhum usuário autenticado na inicialização e token inválido.');
      }
    } catch (e) {
      print('AuthProvider: Erro na inicialização: $e');
      _error = 'Erro ao carregar usuário';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupApiClientCallbacks() {
    ApiClient.onTokenUpdated = (token, refreshToken, expiry) {
      print('AuthProvider: Token atualizado pelo ApiClient');
      
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
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
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Login com biometria
  Future<bool> loginWithBiometrics() async {
    _isLoading = true;
    _error = null;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

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

      _currentUser = await _authService.login(cpf, password);
      final success = _currentUser != null;

      if (success) {
        print(
            'AuthProvider: Login biométrico bem-sucedido para: ${_currentUser!.name}');
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
      
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Login tradicional
  Future<bool> login(String cpf, String password,
      {bool saveBiometric = false, bool rememberMe = false}) async {
    _isLoading = true;
    _error = null;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      print('AuthProvider: Tentando login com CPF: $cpf');
      _currentUser = await _authService.login(cpf, password);
      final success = _currentUser != null;

      if (success) {
        print('AuthProvider: Login bem-sucedido para: ${_currentUser!.name}');
        _lastLoggedCpf = cpf;
        _error = null;

        // Salvar credenciais se solicitado
        if (rememberMe) {
          await SecureStorageService.saveCredentials(
            username: cpf,
            password: password,
            rememberMe: true,
          );
        }

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
      
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
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
        
        // Usar addPostFrameCallback para evitar setState durante build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }

      return success;
    } catch (e) {
      print('AuthProvider: Erro ao renovar token: $e');
      _error = 'Erro ao renovar sessão: $e';
      _currentUser = null;
      
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
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
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      print('AuthProvider: Realizando logout');
      // Salvar o último CPF antes de limpar o usuário
      if (_currentUser != null) {
        _lastLoggedCpf = _currentUser!.cpf;
      }
      await _authService.logout();
      _currentUser = null;
      _error = null;

      // Sempre limpar credenciais salvas ao fazer logout
      await clearSavedCredentials();

      print('AuthProvider: Logout concluído com sucesso');
    } catch (e) {
      print('AuthProvider: Erro durante logout: $e');
      _error = 'Erro ao fazer logout';
    } finally {
      _isLoading = false;
      
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Limpar erro
  void clearError() {
    _error = null;
    
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Método público para forçar login biométrico (pode ser chamado pela tela de login)
  Future<void> forceBiometricLoginIfNeeded() async {
    final biometricEnabled = await BiometricService.isBiometricEnabled();
    if (biometricEnabled && !isAuthenticated) {
      await loginWithBiometrics();
    }
  }

  // Método para fazer login automático com credenciais salvas
  Future<bool> loginWithSavedCredentials() async {
    try {
      // Verificar se há credenciais salvas
      final hasSaved = await SecureStorageService.hasSavedCredentials();
      if (!hasSaved) {
        return false;
      }

      // Obter credenciais salvas
      final credentials = await SecureStorageService.getSavedCredentials();
      final username = credentials['username'];
      final password = credentials['password'];

      if (username == null || password == null) {
        return false;
      }

      // Fazer login com as credenciais salvas
      return await login(username, password, rememberMe: false);
    } catch (e) {
      print('AuthProvider: Erro ao fazer login com credenciais salvas: $e');
      return false;
    }
  }

  // Método para limpar credenciais salvas
  Future<void> clearSavedCredentials() async {
    await SecureStorageService.clearCredentials();
  }
}
