# Jobble (flutter_tcc)

App Flutter do Jobble. O backend fica hospedado no Railway em
`https://jobble-api.up.railway.app`.

## Requisitos

| Ferramenta | Versão usada | Necessário para |
|---|---|---|
| Flutter SDK | 3.47.2 (stable, Dart 3.13.2) | tudo |
| Xcode + CocoaPods | Xcode 15+ | simulador/dispositivo iOS |
| JDK 17 + Android SDK | — | emulador/dispositivo Android |

O `pubspec.yaml` exige `sdk: ^3.11.3`, então qualquer Flutter stable com Dart
3.11+ serve.

### Instalando o Flutter (macOS)

```bash
git clone -b stable https://github.com/flutter/flutter.git ~/development/flutter
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
exec zsh
flutter doctor
```

## Configuração de ambiente

Toda a configuração passa por `--dart-define`, lido em tempo de compilação por
[`lib/core/config/app_config.dart`](lib/core/config/app_config.dart). Não há
nenhum segredo embutido no código.

```bash
cp .env.example .env   # depois ajuste os valores
```

| Variável | Default | Descrição |
|---|---|---|
| `API_BASE_URL` | `https://jobble-api.up.railway.app` | URL base da API, sem barra no final |
| `UPLOADS_BASE_URL` | `$API_BASE_URL/uploads` | URL base das fotos de perfil e portfólio |
| `API_CONNECT_TIMEOUT_SECONDS` | `10` | timeout de conexão do Dio |
| `API_RECEIVE_TIMEOUT_SECONDS` | `15` | timeout de resposta do Dio |
| `ENABLE_HTTP_LOGS` | ligado em debug | log de request/response do Dio |

O `.env` **não** é versionado; o `.env.example` é. Como os valores são
resolvidos em tempo de compilação, **alterar o `.env` exige reiniciar o app** —
hot reload não pega a mudança.

### Apontando para um backend local

```bash
# simulador iOS
API_BASE_URL=http://localhost:3333

# emulador Android (10.0.2.2 é o host visto de dentro do emulador)
API_BASE_URL=http://10.0.2.2:3333
```

## Rodando

```bash
flutter pub get
./scripts/run.sh
```

`scripts/run.sh` lê o `.env` e converte cada linha em `--dart-define`.
Argumentos extras passam direto para o `flutter run`:

```bash
./scripts/run.sh -d "iPhone 17 Pro"
./scripts/run.sh -d chrome
ENV_FILE=.env.staging ./scripts/run.sh
```

Pelo VS Code, use as configurações prontas em `.vscode/launch.json`
(*Jobble (.env)*, *Jobble (Railway)*, *Jobble (backend local — simulador iOS)*,
*Jobble (backend local — emulador Android)*).

Sem os scripts, o equivalente direto é:

```bash
flutter run --dart-define-from-file=.env
```

## Build

```bash
./scripts/build.sh ios --release
./scripts/build.sh apk --release
./scripts/build.sh web --release
```

## Estrutura

Clean Architecture por feature, com `get_it` para injeção de dependência
(`lib/injection_container.dart`) e `flutter_bloc` para estado.

```
lib/
  core/          config, network (Dio), theme, database (sqflite), services, widgets
  features/      auth, home, profile, bids, notifications, services, wallet, ...
    <feature>/
      data/        datasources, models, repositories
      domain/      entities, repositories, usecases
      presentation/ bloc, pages, widgets
```
