import '../repositories/auth_repository.dart';
import '../models/user.dart';

class AuthService {
  final AuthRepository _authRepository = AuthRepository();

  // Login com CPF e senha
  Future<User?> login(String cpf, String password) async {
    try {
      print('AuthService: Iniciando login com CPF: $cpf');
      final user = await _authRepository.login(cpf, password);

      if (user != null) {
        print('AuthService: Login bem-sucedido para o usuário: ${user.name}');
      } else {
        print('AuthService: Login falhou - nenhum usuário retornado');
      }

      return user;
    } catch (e) {
      print('AuthService: Erro durante o login: $e');
      return null;
    }
  }

  // Renovar token
  Future<bool> refreshToken(String token) async {
    try {
      print('AuthService: Tentando renovar token...');
      final newToken = await _authRepository.refreshToken(token);

      if (newToken != null) {
        print('AuthService: Token renovado com sucesso');
        return true;
      } else {
        print('AuthService: Falha ao renovar token');
        return false;
      }
    } catch (e) {
      print('AuthService: Erro durante renovação de token: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      print('AuthService: Iniciando logout');
      await _authRepository.logout();
      print('AuthService: Logout concluído com sucesso');
    } catch (e) {
      print('AuthService: Erro durante o logout: $e');
      rethrow;
    }
  }

  // Obter usuário atual
  Future<User?> getCurrentUser() async {
    try {
      print('AuthService: Verificando usuário atual');
      final user = await _authRepository.getCurrentUser();

      if (user != null) {
        print('AuthService: Usuário atual encontrado: ${user.name}');
      } else {
        print('AuthService: Nenhum usuário atual encontrado');
      }

      return user;
    } catch (e) {
      print('AuthService: Erro ao obter usuário atual: $e');
      return null;
    }
  }
}
