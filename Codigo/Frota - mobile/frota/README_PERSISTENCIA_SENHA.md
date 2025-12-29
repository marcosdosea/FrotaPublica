# Persistência de Senha - Frota Mobile

## Visão Geral

Este documento descreve a implementação da persistência de senha no aplicativo Frota Mobile, baseada no exemplo fornecido no PR https://github.com/fabricadesoftwareufs/AutomacaoSalasMobile/pull/13.

## Funcionalidades Implementadas

### 1. Armazenamento Seguro
- **SecureStorageService**: Serviço que utiliza `flutter_secure_storage` para armazenar credenciais de forma segura
- Armazenamento criptografado no Keychain (iOS) e Keystore (Android)
- Separação entre credenciais de "lembrar senha" e credenciais biométricas

### 2. Opção "Lembrar Senha"
- Checkbox na tela de login para permitir que o usuário salve suas credenciais
- Carregamento automático das credenciais salvas na próxima inicialização
- Login automático se as credenciais estiverem salvas

### 3. Integração com Biometria
- Mantém a funcionalidade biométrica existente
- Prioriza credenciais salvas por "lembrar senha" sobre credenciais biométricas
- Permite usar ambas as funcionalidades simultaneamente

## Como Funciona

### Fluxo de Login

1. **Inicialização da Tela de Login**:
   - Carrega credenciais salvas do armazenamento seguro
   - Preenche automaticamente os campos CPF e senha
   - Marca o checkbox "Lembrar senha" se há credenciais salvas
   - Tenta login automático se as credenciais são válidas

2. **Login Manual**:
   - Usuário preenche CPF e senha
   - Pode marcar "Lembrar senha" para salvar as credenciais
   - Pode ativar biometria para login futuro

3. **Login Biométrico**:
   - Funciona independentemente da opção "lembrar senha"
   - Usa credenciais salvas especificamente para biometria

### Armazenamento de Dados

```dart
// Credenciais salvas por "lembrar senha"
username: "123.456.789-00"
password: "senha123"
remember_me: "true"

// Configuração de biometria
biometric_enabled: "true"
```

## Arquivos Modificados

### Novos Arquivos
- `lib/src/services/secure_storage_service.dart`: Serviço de armazenamento seguro

### Arquivos Modificados
- `lib/src/services/biometric_service.dart`: Integração com SecureStorageService
- `lib/src/providers/auth_provider.dart`: Adicionado suporte a "lembrar senha"
- `lib/src/screens/login_screen.dart`: Interface com checkbox "Lembrar senha"

## Uso da API

### AuthProvider

```dart
// Login com "lembrar senha"
await authProvider.login(
  cpf: "123.456.789-00",
  password: "senha123",
  rememberMe: true,
  saveBiometric: false,
);

// Login automático com credenciais salvas
final success = await authProvider.loginWithSavedCredentials();

// Limpar credenciais salvas
await authProvider.clearSavedCredentials();
```

### SecureStorageService

```dart
// Salvar credenciais
await SecureStorageService.saveCredentials(
  username: "123.456.789-00",
  password: "senha123",
  rememberMe: true,
);

// Obter credenciais salvas
final credentials = await SecureStorageService.getSavedCredentials();

// Verificar se há credenciais salvas
final hasSaved = await SecureStorageService.hasSavedCredentials();
```

## Segurança

- Todas as credenciais são armazenadas de forma criptografada
- Uso do `flutter_secure_storage` que utiliza APIs nativas de segurança
- Separação entre diferentes tipos de armazenamento (lembrar senha vs biometria)
- Limpeza automática de credenciais no logout (se não estiver usando "lembrar senha")

## Compatibilidade

- ✅ iOS (Keychain)
- ✅ Android (Keystore)
- ✅ Funciona com biometria existente
- ✅ Mantém funcionalidades anteriores

## Testes

Para testar a funcionalidade:

1. Faça login com "Lembrar senha" marcado
2. Feche o aplicativo
3. Abra novamente - deve fazer login automático
4. Teste com biometria ativada
5. Teste logout e verifique se as credenciais são mantidas/removidas conforme esperado 