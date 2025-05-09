import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://itetech-001-site1.qtempurl.com/api';
  static const storage = FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  // Obter token JWT armazenado
  static Future<String?> getToken() async {
    return await storage.read(key: _tokenKey);
  }

  // Salvar token JWT
  static Future<void> saveToken(
      String token, String refreshToken, DateTime expiry) async {
    await storage.write(key: _tokenKey, value: token);
    await storage.write(key: _refreshTokenKey, value: refreshToken);
    await storage.write(key: _tokenExpiryKey, value: expiry.toIso8601String());

    // Imprimir para depuração
    print('Token JWT salvo com sucesso!');
  }

  // Remover token JWT (logout)
  static Future<void> removeToken() async {
    await storage.delete(key: _tokenKey);
    await storage.delete(key: _refreshTokenKey);
    await storage.delete(key: _tokenExpiryKey);
  }

  // Verificar se o token está expirado
  static Future<bool> isTokenExpired() async {
    final expiryString = await storage.read(key: _tokenExpiryKey);
    if (expiryString == null) return true;

    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)));
  }

  // Renovar token automaticamente se necessário
  static Future<String?> _getValidToken() async {
    if (await isTokenExpired()) {
      print("Token expirado ou não existe. Tentando fazer refresh...");
      final token = await storage.read(key: _tokenKey);
      if (token != null) {
        try {
          // Implementando a chamada ao endpoint de refresh token
          final response = await http.post(
            Uri.parse('$baseUrl/Auth/refresh-token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token}),
          );

          print("Resposta do refresh token: ${response.statusCode}");

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);

            if (data['success'] == true) {
              final newToken = data['token'];

              // Salvar o novo token
              await saveToken(
                  newToken,
                  newToken, // Usando o mesmo token como refreshToken
                  DateTime.now().add(const Duration(days: 7)));

              print("Token renovado com sucesso");
              return newToken;
            } else {
              print("Falha ao renovar token: ${data['message']}");
            }
          } else {
            print("Erro ao renovar token. Status: ${response.statusCode}");
          }

          // Se chegou aqui, não conseguiu renovar o token
          await removeToken();
          return null;
        } catch (e) {
          print('Erro ao renovar token: $e');
          // Em caso de erro, força novo login
          await removeToken();
          return null;
        }
      }
      return null;
    }

    final token = await getToken();
    if (token != null) {
      print("Token válido encontrado.");
    }
    return token;
  }

  // GET Request com autenticação automática
  static Future<http.Response> get(String endpoint) async {
    final token = await _getValidToken();
    final headers = {
      'Content-Type': 'application/json',
      'accept': 'text/plain',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
  }

  // POST Request com autenticação automática
  static Future<http.Response> post(String endpoint, dynamic data) async {
    final token = await _getValidToken();
    final headers = {
      'Content-Type': 'application/json',
      'accept': 'text/plain',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  // PUT Request com autenticação automática
  static Future<http.Response> put(String endpoint, dynamic data) async {
    final token = await _getValidToken();
    final headers = {
      'Content-Type': 'application/json',
      'accept': 'text/plain',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  // DELETE Request com autenticação automática
  static Future<http.Response> delete(String endpoint) async {
    final token = await _getValidToken();
    final headers = {
      'Content-Type': 'application/json',
      'accept': 'text/plain',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
  }
}
