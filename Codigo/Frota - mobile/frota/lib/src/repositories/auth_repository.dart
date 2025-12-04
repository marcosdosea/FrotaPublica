import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/api_client.dart';
import 'package:flutter/material.dart';

class AuthRepository {
  static const String _userKey = 'current_user';

  // Configuração centralizada da API (mesma do ApiClient)
  static const String _host = 'itetech-001-site1.qtempurl.com';
  static const String _apiPath = '/api';

  // Métodos auxiliares para construir URLs
  static String _buildUrl(String protocol, String endpoint) {
    final baseUrl = protocol == 'https'
        ? 'http://$_host$_apiPath'
        : 'http://$_host$_apiPath';
    return '$baseUrl/$endpoint';
  }

  // Salvar os dados do usuário localmente
  Future<void> _saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      print('Dados do usuário salvos localmente: ${user.name}');
    } catch (e) {
      print('Erro ao salvar dados do usuário: $e');
    }
  }

  // Obter os dados do usuário salvos localmente
  Future<User?> _getSavedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_userKey);

      if (userString != null) {
        final userData = jsonDecode(userString);
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Erro ao obter dados do usuário: $e');
      return null;
    }
  }

  // Remover os dados do usuário salvos localmente
  Future<void> _removeSavedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      print('Dados do usuário removidos localmente');
    } catch (e) {
      print('Erro ao remover dados do usuário: $e');
    }
  }

  Future<User?> login(String cpf, String password) async {
    try {
      // Limpa o CPF para enviar apenas os números
      final cleanCpf = cpf.replaceAll('.', '').replaceAll('-', '');

      final response = await ApiClient.post(
          'Auth/login', {'userName': cleanCpf, 'password': password});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final token = data['token'];
          final userName = data['userName'];

          await ApiClient.saveToken(
              token,
              token,
              DateTime.now().add(const Duration(
                  days: 7))
              );

          final user = User(
            id: userName,
            name: data['nome'] ?? userName,
            email: userName,
            cpf: userName,
            role: data['role'] ?? 'Motorista',
            unidadeAdministrativaId: 1,
          );

          await _saveUserData(user);

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
      await ApiClient.removeToken();
      await _removeSavedUserData();
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

      final savedUser = await _getSavedUserData();
      if (savedUser != null) {
        print('Usuário recuperado do armazenamento local: ${savedUser.name}');
        return savedUser;
      }

      return null;
    } catch (e) {
      print('Erro ao obter usuário atual: $e');
      return null;
    }
  }
}
