import 'dart:convert';
import '../models/user.dart';
import '../utils/api_client.dart';

class AuthRepository {
  Future<User?> login(String cpf, String password) async {
    try {
      // Limpa o CPF para enviar apenas os números
      final cleanCpf = cpf.replaceAll('.', '').replaceAll('-', '');

      final response = await ApiClient.post(
          'Auth/login', {'userName': cleanCpf, 'password': password});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // Salvar o token JWT
          final token = data['token'];
          final userName = data['userName'];

          // Como não temos refreshToken na resposta, usamos o mesmo token
          await ApiClient.saveToken(
              token,
              token, // Usando o mesmo token como refreshToken
              DateTime.now().add(const Duration(
                  days: 7)) // Expira em 7 dias (conforme JWT no exemplo)
              );

          // Construir um usuário básico com as informações da resposta
          final user = User(
            id: userName,
            name: data['nome'] ?? userName,
            email: userName,
            cpf: userName,
            role: data['role'] ?? 'Motorista',
            unidadeAdministrativaId: 1, // Valor padrão (será atualizado depois)
          );

          return user;
        } else {
          print('Login falhou: ${data['message']}');
          return null;
        }
      }

      return null;
    } catch (e) {
      print('Erro ao realizar login: $e');
      return null;
    }
  }

  Future<String?> refreshToken(String token) async {
    try {
      print('Solicitando refresh do token...');
      final response =
          await ApiClient.post('Auth/refresh-token', {'token': token});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final newToken = data['token'];

          // Atualizar o token armazenado
          await ApiClient.saveToken(
              newToken,
              newToken, // Usando o mesmo token como refreshToken
              DateTime.now().add(const Duration(days: 7)));

          print('Token renovado com sucesso');
          return newToken;
        } else {
          print('Falha ao renovar token: ${data['message']}');
        }
      }

      return null;
    } catch (e) {
      print('Erro ao renovar token: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      // Apenas remove o token localmente
      await ApiClient.removeToken();
    } catch (e) {
      print('Erro ao realizar logout: $e');
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      // Verifica se o token existe e está válido
      final token = await ApiClient.getToken();
      if (token == null) return null;

      // Obter usuário a partir do token JWT
      // Nesse caso simplificado, retornamos um usuário básico
      return User(
        id: '1',
        name: 'Motorista',
        email: 'motorista@example.com',
        cpf: '12345678900',
        role: 'Motorista',
        unidadeAdministrativaId: 1,
      );
    } catch (e) {
      print('Erro ao obter usuário atual: $e');
      return null;
    }
  }
}
