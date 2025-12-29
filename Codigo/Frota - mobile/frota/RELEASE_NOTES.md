# Notas de Release - Preparação para Play Store

## Arquivo .aab Gerado
✅ **app-release.aab** gerado com sucesso!
Localização: `build/app/outputs/bundle/release/app-release.aab`
Tamanho: 48.4MB

## Configurações de Produção Aplicadas

### 1. Assinatura do App
- ✅ Keystore criado: `android/upload-keystore.jks`
- ✅ Configuração de assinatura adicionada ao `build.gradle`
- ⚠️ **IMPORTANTE**: As senhas padrão são "android" - considere alterar antes da publicação final
- ⚠️ **IMPORTANTE**: Mantenha o arquivo `upload-keystore.jks` em local seguro e faça backup! Ele é necessário para todas as atualizações futuras do app.

### 2. Variáveis de Produção
- ✅ URL da API: `itetech-001-site1.qtempurl.com`
- ✅ Protocolo: HTTP (configurado no código)
- ✅ Network Security Config: Configurado para permitir cleartext traffic

### 3. Versão do App
- ✅ Version Name: 1.0.0
- ✅ Version Code: 1

### 4. Configurações do Build
- ✅ Build Type: Release
- ✅ Signing Config: Release (com keystore)
- ✅ Minify: Desabilitado
- ✅ Shrink Resources: Desabilitado

## Próximos Passos para Publicação

1. **Faça backup da keystore** (`android/upload-keystore.jks`) em local seguro
2. **Considere alterar as senhas** da keystore se necessário
3. **Faça upload do arquivo .aab** para o Google Play Console
4. **Configure as informações do app** na Play Store (descrição, screenshots, etc.)
5. **Teste em ambiente de produção** antes de publicar para todos os usuários

## Localização dos Arquivos Importantes

- **Keystore**: `android/upload-keystore.jks`
- **Configuração da Keystore**: `android/key.properties`
- **Arquivo .aab**: `build/app/outputs/bundle/release/app-release.aab`

## Notas Adicionais

- A URL da API atual usa HTTP. Para maior segurança em produção, considere migrar para HTTPS.
- O arquivo `key.properties` contém senhas - considere adicioná-lo ao `.gitignore` se ainda não estiver.

