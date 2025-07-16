import 'package:local_auth/local_auth.dart';
import 'secure_storage_service.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  // Verificar se o dispositivo suporta biometria
  static Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      print('Erro ao verificar suporte biométrico: $e');
      return false;
    }
  }

  // Verificar se há biometrias cadastradas no dispositivo
  static Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      print('Erro ao verificar biometrias disponíveis: $e');
      return false;
    }
  }

  // Obter tipos de biometria disponíveis
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Erro ao obter biometrias disponíveis: $e');
      return [];
    }
  }

  // Verificar se a biometria está habilitada pelo usuário
  static Future<bool> isBiometricEnabled() async {
    return await SecureStorageService.isBiometricEnabled();
  }

  // Habilitar/desabilitar biometria
  static Future<void> setBiometricEnabled(bool enabled) async {
    await SecureStorageService.setBiometricEnabled(enabled);
  }

  // Autenticar com biometria
  static Future<bool> authenticateWithBiometrics() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Use sua biometria para fazer login no app',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      print('Erro na autenticação biométrica: $e');
      return false;
    }
  }

  // Salvar credenciais para uso com biometria
  static Future<void> saveCredentials(String cpf, String password) async {
    await SecureStorageService.saveBiometricCredentials(
      username: cpf,
      password: password,
    );
  }

  // Obter credenciais salvas
  static Future<Map<String, String?>> getSavedCredentials() async {
    return await SecureStorageService.getSavedCredentials();
  }

  // Limpar credenciais salvas
  static Future<void> clearSavedCredentials() async {
    await SecureStorageService.clearBiometricCredentials();
  }

  // Configurar biometria (solicitar autenticação para confirmar)
  static Future<bool> setupBiometric() async {
    try {
      // Verificar se o dispositivo suporta biometria
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return false;
      }

      // Verificar se há biometrias cadastradas de forma confiável
      final availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return false;
      }

      // Solicitar autenticação para confirmar a configuração
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Confirme sua identidade para habilitar a biometria',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        await setBiometricEnabled(true);
        return true;
      }

      return false;
    } catch (e) {
      print('Erro ao configurar biometria: $e');
      return false;
    }
  }
}
