# 📱 Guia Completo: Publicação de Apps Flutter na Google Play Store

Este guia contém todas as instruções necessárias para publicar um app Flutter na Google Play Store, incluindo configuração de assinatura, build e upload do arquivo .aab.

---

## 📋 Pré-requisitos

- Flutter instalado e configurado
- Conta de desenvolvedor Google Play (taxa única de $25)
- Java JDK instalado (para uso do keytool)
- Projeto Flutter configurado e funcionando

---

## 🔐 Passo 1: Criar Keystore para Assinatura

O keystore é essencial para assinar o app. **GUARDE ESTE ARQUIVO EM LOCAL SEGURO** - você precisará dele para todas as atualizações futuras!

### 1.1. Gerar o Keystore

Execute o comando abaixo no diretório `android/` do seu projeto:

```bash
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Parâmetros importantes:**
- `-keystore upload-keystore.jks`: Nome do arquivo keystore
- `-keyalg RSA`: Algoritmo de criptografia
- `-keysize 2048`: Tamanho da chave (recomendado: 2048 ou 4096)
- `-validity 10000`: Validade em dias (10000 ≈ 27 anos)
- `-alias upload`: Alias da chave (usado no build)

**Durante a criação, você será solicitado a informar:**
- Senha do keystore (guarde com segurança!)
- Senha da chave (pode ser a mesma do keystore)
- Informações pessoais (nome, organização, cidade, estado, país, etc.)

⚠️ **IMPORTANTE**: Escolha senhas fortes e guarde-as em local seguro!

### 1.2. Mover o Keystore

Mova o arquivo `upload-keystore.jks` para o diretório `android/` do seu projeto (mesmo diretório onde está o `build.gradle`).

---

## ⚙️ Passo 2: Configurar key.properties

Crie o arquivo `android/key.properties` com as seguintes informações:

```properties
storePassword=SUA_SENHA_KEYSTORE
keyPassword=SUA_SENHA_CHAVE
keyAlias=upload
storeFile=upload-keystore.jks
```

**Substitua:**
- `SUA_SENHA_KEYSTORE`: A senha do keystore que você definiu
- `SUA_SENHA_CHAVE`: A senha da chave (pode ser a mesma)

**Exemplo:**
```properties
storePassword=MinhaSenhaSegura123!
keyPassword=MinhaSenhaSegura123!
keyAlias=upload
storeFile=upload-keystore.jks
```

---

## 🔧 Passo 3: Configurar build.gradle

Edite o arquivo `android/app/build.gradle` e adicione/atualize as seguintes configurações:

### 3.1. Adicionar leitura do key.properties (no início do arquivo, após os plugins)

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

### 3.2. Configurar signingConfigs (dentro do bloco android)

```gradle
signingConfigs {
    release {
        if (keystorePropertiesFile.exists()) {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            def keystorePath = keystoreProperties['storeFile']
            storeFile keystorePath ? rootProject.file(keystorePath) : null
            storePassword keystoreProperties['storePassword']
        }
    }
}
```

### 3.3. Atualizar buildTypes (dentro do bloco android)

```gradle
buildTypes {
    release {
        signingConfig = signingConfigs.release
        minifyEnabled = false  // Altere para true se quiser minificar o código
        shrinkResources = false  // Altere para true se quiser reduzir recursos
    }
}
```

**Exemplo completo do build.gradle:**

```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.seudominio.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8
    }

    defaultConfig {
        applicationId = "com.seudominio.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                def keystorePath = keystoreProperties['storeFile']
                storeFile keystorePath ? rootProject.file(keystorePath) : null
                storePassword keystoreProperties['storePassword']
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.release
            minifyEnabled = false
            shrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
```

---

## 📝 Passo 4: Configurar Versão do App

Edite o arquivo `pubspec.yaml` e defina a versão do app:

```yaml
version: 1.0.0+1
```

**Formato:** `versionName+buildNumber`
- `1.0.0`: Version Name (versão visível aos usuários)
- `1`: Version Code (número interno, deve incrementar a cada release)

**Regras:**
- Version Code deve ser único e sempre incrementar
- Version Name pode seguir Semantic Versioning (ex: 1.0.0, 1.0.1, 1.1.0, 2.0.0)
- Para nova versão: `version: 1.0.1+2` (incrementa ambos os números)

---

## 🌐 Passo 5: Verificar Variáveis de Produção

Antes de fazer o build, verifique se todas as variáveis de ambiente estão configuradas para produção:

### 5.1. Verificar URL da API

Verifique os arquivos onde a URL da API está configurada:
- `lib/src/utils/api_client.dart`
- `lib/src/repositories/auth_repository.dart`
- Qualquer outro arquivo que faça chamadas de API

**Garanta que:**
- ✅ URL de produção está configurada (não localhost ou IP local)
- ✅ Protocolo correto (HTTP/HTTPS)
- ✅ Portas corretas se necessário

### 5.2. Verificar Configurações de Ambiente

Se você usa arquivos `.env` ou configurações por flavor:
- Certifique-se de que as variáveis de produção estão ativas
- Verifique chaves de API (Google Maps, Firebase, etc.)
- Confirme endpoints de produção

---

## 🔒 Passo 6: Proteger Arquivos Sensíveis

Adicione ao arquivo `.gitignore` na raiz do projeto Flutter:

```gitignore
# Keystore files - DO NOT COMMIT THESE!
*.jks
*.keystore
**/key.properties
```

**NUNCA faça commit de:**
- Arquivos `.jks` ou `.keystore`
- Arquivo `key.properties`
- Qualquer arquivo com senhas ou chaves privadas

---

## 🏗️ Passo 7: Build do App

### 7.1. Limpar o Projeto

```bash
cd caminho/do/seu/projeto
flutter clean
```

### 7.2. Instalar Dependências

```bash
flutter pub get
```

### 7.3. Gerar o Arquivo .aab

```bash
flutter build appbundle --release
```

**O arquivo será gerado em:**
```
build/app/outputs/bundle/release/app-release.aab
```

### 7.4. Verificar o Arquivo Gerado

O arquivo `.aab` (Android App Bundle) é o formato requerido pela Google Play Store desde 2021. Ele é otimizado e menor que um APK tradicional.

---

## 📤 Passo 8: Upload na Google Play Console

### 8.1. Acessar o Console

1. Acesse [Google Play Console](https://play.google.com/console)
2. Faça login com sua conta de desenvolvedor
3. Selecione ou crie seu app

### 8.2. Fazer Upload do .aab

1. Vá para **Produção** (ou **Rascunho interno/Teste** para testes)
2. Clique em **Criar nova versão**
3. Faça upload do arquivo `app-release.aab`
4. Preencha as **Notas da versão** (o que mudou nesta versão)
5. Clique em **Salvar**

### 8.3. Configurações Adicionais (se necessário)

- **Conteúdo do app**: Screenshots, descrição, ícone
- **Classificação de conteúdo**: Informações sobre o conteúdo do app
- **Preço e distribuição**: Países e preço (se aplicável)
- **Política de privacidade**: URL obrigatória desde maio/2021

### 8.4. Revisar e Publicar

1. Revise todas as informações
2. Clique em **Revisar versão**
3. Se tudo estiver correto, clique em **Iniciar rollout para produção**

⚠️ **Tempo de revisão**: A Google geralmente leva algumas horas até 7 dias para revisar o app.

---

## 🔄 Atualizações Futuras

Para publicar atualizações do mesmo app:

1. **Incremente a versão** no `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # Incrementa version name e version code
   ```

2. **Verifique variáveis de produção** (se houver mudanças)

3. **Gere novo .aab**:
   ```bash
   flutter clean
   flutter pub get
   flutter build appbundle --release
   ```

4. **Use o MESMO keystore** (importante!)

5. **Faça upload** na Play Console na mesma ficha do app

---

## ⚠️ Problemas Comuns e Soluções

### Erro: "Keystore file not found"

**Solução:**
- Verifique se o arquivo `upload-keystore.jks` está em `android/`
- Verifique se o caminho no `key.properties` está correto
- Use `rootProject.file()` no build.gradle para resolver o caminho

### Erro: "Keystore was tampered with, or password was incorrect"

**Solução:**
- Verifique se as senhas no `key.properties` estão corretas
- Certifique-se de que não há espaços extras nas senhas

### Erro: "Version code has already been used"

**Solução:**
- Incremente o version code no `pubspec.yaml`
- Exemplo: Se a última versão foi `1.0.0+5`, use `1.0.1+6`

### App não assina corretamente

**Solução:**
- Verifique se o `signingConfig` está usando `signingConfigs.release`
- Confirme que o `key.properties` existe e está no lugar correto
- Verifique se o alias no `key.properties` corresponde ao alias usado na criação do keystore

---

## 📦 Backup e Segurança

### Checklist de Backup

- [ ] Keystore (`upload-keystore.jks`) em local seguro
- [ ] Senhas do keystore em gerenciador de senhas
- [ ] Informações do alias da chave
- [ ] Cópia do `key.properties` (opcional, mas útil)

### O que fazer se perder o keystore?

❌ **NÃO É POSSÍVEL** recuperar ou atualizar o app se você perder o keystore.

Você terá que:
1. Criar um novo app na Play Store
2. Perder todas as avaliações e downloads do app antigo
3. Os usuários terão que desinstalar o app antigo e instalar o novo

**Por isso, faça backup do keystore imediatamente após criá-lo!**

---

## 📚 Referências e Recursos Úteis

- [Documentação Flutter - Build and Release](https://docs.flutter.dev/deployment/android)
- [Google Play Console](https://play.google.com/console)
- [Android App Bundle](https://developer.android.com/guide/app-bundle)
- [Keytool Documentation](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/keytool.html)

---

## ✅ Checklist Final Antes de Publicar

- [ ] Keystore criado e em local seguro
- [ ] `key.properties` configurado corretamente
- [ ] `build.gradle` atualizado com signingConfigs
- [ ] Versão do app incrementada no `pubspec.yaml`
- [ ] Variáveis de produção verificadas (URLs, APIs, etc.)
- [ ] Arquivos sensíveis adicionados ao `.gitignore`
- [ ] Build do .aab gerado com sucesso
- [ ] Backup do keystore feito
- [ ] App testado localmente em modo release
- [ ] Informações do app preenchidas na Play Console
- [ ] Política de privacidade adicionada (se necessário)

---

## 🎯 Resumo Rápido (Comando Único)

Para gerar o .aab rapidamente após configurar tudo:

```bash
flutter clean && flutter pub get && flutter build appbundle --release
```

O arquivo estará em: `build/app/outputs/bundle/release/app-release.aab`

---

**Última atualização:** 2025

**Dica:** Mantenha este guia atualizado com suas próprias práticas e configurações específicas do seu projeto!

