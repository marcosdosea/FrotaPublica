import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Configuração centralizada da API
  static const String _host = 'itetech-001-site1.qtempurl.com';
  static const String _apiPath = '/api';
  static const String _httpsBaseUrl = 'http://$_host$_apiPath';
  static const String _httpBaseUrl = 'http://$_host$_apiPath';

  static const storage = FlutterSecureStorage();

  static final _client = HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

  static final _httpClient = http.Client();

  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  // Callback para notificar quando o token é atualizado
  static Function(String token, String refreshToken, DateTime expiry)?
      onTokenUpdated;

  // Callback para notificar quando o token expira
  static Function()? onTokenExpired;

  // Métodos auxiliares para construir URLs
  static String _buildUrl(String protocol, String endpoint) {
    final baseUrl = protocol == 'https' ? _httpsBaseUrl : _httpBaseUrl;
    return '$baseUrl/$endpoint';
  }

  static Uri _buildUri(String protocol, String endpoint) {
    return Uri.parse(_buildUrl(protocol, endpoint));
  }

  // Obter token JWT armazenado
  static Future<String?> getToken() async {
    return await storage.read(key: _tokenKey);
  }

  // Obter refresh token armazenado
  static Future<String?> getRefreshToken() async {
    return await storage.read(key: _refreshTokenKey);
  }

  // Salvar token JWT
  static Future<void> saveToken(
      String token, String refreshToken, DateTime expiry) async {
    await storage.write(key: _tokenKey, value: token);
    await storage.write(key: _refreshTokenKey, value: refreshToken);
    await storage.write(key: _tokenExpiryKey, value: expiry.toIso8601String());

    // Notificar sobre a atualização do token
    onTokenUpdated?.call(token, refreshToken, expiry);

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

  // Renovar token usando refresh token
  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        print('Nenhum refresh token encontrado');
        return false;
      }

      final uri = Uri.parse('$_httpsBaseUrl/Auth/refresh-token');
      final request = await _client.postUrl(uri);
      request.headers.add('Content-Type', 'application/json');
      final jsonBody = utf8.encode(jsonEncode({'refreshToken': refreshToken}));
      request.add(jsonBody);
      final httpResponse = await request.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      final response = http.Response(
        responseBody,
        httpResponse.statusCode,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        isRedirect: httpResponse.isRedirect,
      );

      print("Resposta do refresh token: \\${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final newToken = data['token'];
          final newRefreshToken = data['refreshToken'] ?? refreshToken;

          // Salvar o novo token
          await saveToken(newToken, newRefreshToken,
              DateTime.now().add(const Duration(days: 7)));

          print("Token renovado com sucesso");
          return true;
        } else {
          print("Falha ao renovar token: ${data['message']}");
        }
      } else {
        print("Erro ao renovar token. Status: ${response.statusCode}");
      }

      // Se chegou aqui, não conseguiu renovar o token
      await removeToken();
      onTokenExpired?.call();
      return false;
    } catch (e) {
      print('Erro ao renovar token: $e');
      // Em caso de erro força novo login
      await removeToken();
      onTokenExpired?.call();
      return false;
    }
  }

  // Renovar token automaticamente se necessário
  static Future<String?> _getValidToken() async {
    if (await isTokenExpired()) {
      print("Token expirado ou não existe. Tentando fazer refresh...");

      final success = await refreshToken();
      if (!success) {
        print("Não foi possível renovar o token");
        return null;
      }
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
      'accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final uri = Uri.parse('$_httpsBaseUrl/$endpoint');
      final request = await _client.getUrl(uri);

      // Adicionar headers
      headers.forEach((key, value) {
        request.headers.add(key, value);
      });

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      return http.Response(
        responseBody,
        response.statusCode,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token'
        },
        isRedirect: response.isRedirect,
      );
    } catch (e) {
      print('Erro na requisição GET: $e');
      return http.Response('{"error": "$e"}', 500);
    }
  }

  // POST Request com autenticação automática
  static Future<http.Response> post(String endpoint, dynamic data) async {
    final token = await _getValidToken();
    final headers = {
      'Content-Type': 'application/json',
      'accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final uri = Uri.parse('$_httpsBaseUrl/$endpoint');
      final request = await _client.postUrl(uri);

      // Adicionar headers
      headers.forEach((key, value) {
        request.headers.add(key, value);
      });

      // Adicionar corpo da requisição
      final jsonBody = utf8.encode(jsonEncode(data));
      request.add(jsonBody);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      return http.Response(
        responseBody,
        response.statusCode,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token'
        },
        isRedirect: response.isRedirect,
      );
    } catch (e) {
      print('Erro na requisição POST: $e');
      return http.Response('{"error": "$e"}', 500);
    }
  }

  // PUT Request com autenticação automática
  static Future<http.Response> put(String endpoint, dynamic data) async {
    final token = await _getValidToken();
    final headers = {
      'Content-Type': 'application/json',
      'accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final uri = Uri.parse('$_httpsBaseUrl/$endpoint');
      final request = await _client.putUrl(uri);

      // Adicionar headers
      headers.forEach((key, value) {
        request.headers.add(key, value);
      });

      // Adicionar corpo da requisição
      final jsonBody = utf8.encode(jsonEncode(data));
      request.add(jsonBody);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      return http.Response(
        responseBody,
        response.statusCode,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token'
        },
        isRedirect: response.isRedirect,
      );
    } catch (e) {
      print('Erro na requisição PUT: $e');
      return http.Response('{"error": "$e"}', 500);
    }
  }

  // DELETE Request com autenticação automática
  static Future<http.Response> delete(String endpoint) async {
    final token = await _getValidToken();
    final headers = {
      'Content-Type': 'application/json',
      'accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final uri = Uri.parse('$_httpsBaseUrl/$endpoint');
      final request = await _client.deleteUrl(uri);

      // Adicionar headers
      headers.forEach((key, value) {
        request.headers.add(key, value);
      });

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      return http.Response(
        responseBody,
        response.statusCode,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token'
        },
        isRedirect: response.isRedirect,
      );
    } catch (e) {
      print('Erro na requisição DELETE: $e');
      return http.Response('{"error": "$e"}', 500);
    }
  }
}
