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

  // Refresh Token
  Future<bool> refreshToken() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('AuthProvider: Tentando renovar token...');
      final token = await ApiClient.getToken();

      if (token == null) {
        print('AuthProvider: Nenhum token disponível para renovação');
        _error = 'Nenhum token disponível';
        return false;
      }

      final success = await _authService.refreshToken(token);

      if (success) {
        print('AuthProvider: Token renovado com sucesso');
        _error = null;
      } else {
        print('AuthProvider: Falha ao renovar token');
        _error = 'Falha ao renovar sessão';
        // Se não conseguir renovar, faz logout
        await logout();
      }

      return success;
    } catch (e) {
      print('AuthProvider: Erro ao renovar token: $e');
      _error = 'Erro ao renovar sessão: $e';
      // Em caso de erro, faz logout
      await logout();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
