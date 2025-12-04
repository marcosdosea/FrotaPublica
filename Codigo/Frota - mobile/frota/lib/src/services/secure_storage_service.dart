import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Chaves para armazenamento seguro
  static const String _usernameKey = 'username';
  static const String _passwordKey = 'password';
  static const String _rememberMeKey = 'remember_me';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // Salvar credenciais de forma segura
  static Future<void> saveCredentials({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      if (rememberMe) {
        await _storage.write(key: _usernameKey, value: username);
        await _storage.write(key: _passwordKey, value: password);
        await _storage.write(key: _rememberMeKey, value: 'true');
      } else {
        await clearCredentials();
      }
    } catch (e) {
      print('Erro ao salvar credenciais: $e');
    }
  }

  // Obter credenciais salvas
  static Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final rememberMe = await _storage.read(key: _rememberMeKey);

      if (rememberMe == 'true') {
        final username = await _storage.read(key: _usernameKey);
        final password = await _storage.read(key: _passwordKey);

        return {
          'username': username,
          'password': password,
        };
      }

      return {'username': null, 'password': null};
    } catch (e) {
      print('Erro ao obter credenciais salvas: $e');
      return {'username': null, 'password': null};
    }
  }

  // Limpar credenciais salvas
  static Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: _usernameKey);
      await _storage.delete(key: _passwordKey);
      await _storage.delete(key: _rememberMeKey);
    } catch (e) {
      print('Erro ao limpar credenciais: $e');
    }
  }

  // Verificar se há credenciais salvas
  static Future<bool> hasSavedCredentials() async {
    try {
      final rememberMe = await _storage.read(key: _rememberMeKey);
      return rememberMe == 'true';
    } catch (e) {
      print('Erro ao verificar credenciais salvas: $e');
      return false;
    }
  }

  // Salvar configuração de biometria
  static Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
          key: _biometricEnabledKey, value: enabled ? 'true' : 'false');
    } catch (e) {
      print('Erro ao salvar configuração de biometria: $e');
    }
  }

  // Verificar se biometria está habilitada
  static Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _storage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      print('Erro ao verificar configuração de biometria: $e');
      return false;
    }
  }

  // Salvar credenciais para biometria
  static Future<void> saveBiometricCredentials({
    required String username,
    required String password,
  }) async {
    try {
      await _storage.write(key: _usernameKey, value: username);
      await _storage.write(key: _passwordKey, value: password);
      await setBiometricEnabled(true);
    } catch (e) {
      print('Erro ao salvar credenciais biométricas: $e');
    }
  }

  // Limpar credenciais biométricas
  static Future<void> clearBiometricCredentials() async {
    try {
      await clearCredentials();
      await setBiometricEnabled(false);
    } catch (e) {
      print('Erro ao limpar credenciais biométricas: $e');
    }
  }
}
