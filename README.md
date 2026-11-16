# voz-urbana
Aplicação móvel para centralização de mídias como fotos e vídeos de localidades em uma região.

## Deploy (web)

O app é publicado como site estático na hospedagem (cPanel/Apache), em `https://<domínio>/voz_urbana/`.
O deploy é automático: o workflow `.github/workflows/deploy-web.yml` roda quando uma tag `v*` é enviada.
Ele faz `flutter analyze` e `flutter test`, depois `flutter build web --base-href /voz_urbana/`, e envia `build/web/` via **FTPS**,
mandando só os arquivos alterados. Se a análise ou os testes falharem, nada é publicado.

### Publicar uma nova versão

```bash
git tag v1.0.1
git push origin v1.0.1
```

Acompanhe na aba **Actions** do repositório. Se o celular continuar mostrando a versão antiga, recarregue a página uma vez.

### Cache do Cloudflare

A hospedagem serve o site pelo Cloudflare, que guarda arquivos `.js` por até 4h.
Como o `main.dart.js` do Flutter tem sempre o mesmo nome, o workflow acrescenta a tag na URL dos arquivos de entrada
(`flutter_bootstrap.js?v=vX.Y.Z` e `main.dart.js?v=vX.Y.Z`), para a versão nova ser baixada logo após o deploy.
**Use sempre uma tag nova** (`v1.0.2`, `v1.0.3`…). Reaproveitar uma tag reutiliza o cache antigo.

### Configuração inicial (uma vez só)

1. **Conta FTP restrita:** no cPanel, em *Contas de FTP*, crie o usuário `deploy_voz` com o diretório `public_html/voz_urbana`.
   Assim a conta só tem acesso a essa pasta.
2. **Secrets do GitHub** (*Settings → Secrets and variables → Actions*):

   | Secret | Valor |
   |---|---|
   | `FTP_SERVER` | Nome do servidor da hospedagem (o host que aparece na URL do cPanel, ex.: `brNNN.hostgator.com.br`). Não use o domínio do site, porque o certificado do FTPS é emitido para o nome do servidor. |
   | `FTP_USERNAME` | Usuário completo da conta FTP (ex.: `deploy_voz@<domínio>`) |
   | `FTP_PASSWORD` | Senha da conta FTP |

   Também dá para cadastrar pela linha de comando: `gh secret set FTP_SERVER -R kauaamado/voz_urbana` (o comando pede o valor).
3. **SSL:** no cPanel, em *SSL/TLS Status*, clique em *Run AutoSSL*. O `.htaccess` força HTTPS.

### Deploy manual (alternativa)

```bash
flutter build web --release --base-href /voz_urbana/
V=v$(date +%Y%m%d%H%M)   # versão para driblar o cache do Cloudflare
sed -i "s|src=\"flutter_bootstrap.js\"|src=\"flutter_bootstrap.js?v=$V\"|" build/web/index.html
sed -i "s|\"mainJsPath\":\"main.dart.js\"|\"mainJsPath\":\"main.dart.js?v=$V\"|" build/web/flutter_bootstrap.js
cd build/web && zip -r ../voz_urbana.zip .
```

No *Gerenciador de arquivos* do cPanel, envie o zip para `public_html/voz_urbana/`, use *Extract* e apague o `.zip` depois.
Para ver o `.htaccess`, ative *Settings → Show Hidden Files*.

### Sobre o `web/.htaccess`

O Flutter copia esse arquivo para o build. Ele:
- força HTTPS;
- redireciona rotas inexistentes para o `index.html`;
- impede a listagem de diretórios;
- bloqueia arquivos que começam com ponto (`.env`, `.ftp-deploy-sync-state.json`);
- define headers de segurança;
- desativa o cache dos arquivos de entrada, para o celular sempre carregar a versão nova.

> Na web, câmera e GPS só funcionam em HTTPS. O `.htaccess` libera esses recursos apenas para o próprio site (`Permissions-Policy`).
