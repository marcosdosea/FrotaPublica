import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/api_client.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

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
        print(
            'AuthProvider: Usuário autenticado na inicialização: ${_currentUser!.name}');
      } else {
        print('AuthProvider: Nenhum usuário autenticado na inicialização');
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
      // O token foi renovado automaticamente, apenas notificar os listeners
      // para que a UI seja atualizada se necessário
      notifyListeners();
    };

    ApiClient.onTokenExpired = () {
      print('AuthProvider: Token expirou e não pôde ser renovado');
      // Token expirou e não foi possível renovar - fazer logout
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

  // Login
  Future<bool> login(String cpf, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('AuthProvider: Tentando login com CPF: $cpf');
      _currentUser = await _authService.login(cpf, password);
      final success = _currentUser != null;

      if (success) {
        print('AuthProvider: Login bem-sucedido para: ${_currentUser!.name}');
        _error = null;
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

      // Usar o método refreshToken do ApiClient que já lida com toda a lógica
      final success = await ApiClient.refreshToken();

      if (success) {
        print('AuthProvider: Token renovado com sucesso');
        _error = null;
        // Não precisa notificar aqui pois o callback onTokenUpdated já fará isso
      } else {
        print('AuthProvider: Falha ao renovar token');
        _error = 'Falha ao renovar sessão';
        // Se não conseguir renovar, marca como não autenticado
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