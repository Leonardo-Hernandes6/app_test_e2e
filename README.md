# App de Tarefas — demonstração de testes E2E

App Flutter de tarefas (cadastro, login e CRUD de tarefas) feito para demonstrar uma
suíte de testes **ponta a ponta (E2E)**. O app conversa com uma API REST de verdade
(`server/`), e o E2E roda o app inteiro contra ela, **sem nenhum mock**.

## Como rodar

### Pré-requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) 3.41 ou mais novo (o Dart já vem junto). Confira com `flutter doctor`.
- Um aparelho para o E2E:
  - **iOS:** macOS com Xcode e um simulador;
  - **Android:** Android Studio com um emulador, em qualquer sistema.
- Para usar o script `scripts/run_e2e.sh`: `bash` e `curl`. No macOS e no Linux eles já vêm instalados; no Windows, use o Git Bash ou o WSL, ou rode o E2E pelos passos manuais mais abaixo.
- A porta `8080` livre, usada pela API de demonstração.

### Primeira vez

Na raiz do projeto, instale as dependências do app e da API:

```bash
flutter pub get
cd server && dart pub get && cd ..
```

### Escolher o aparelho

Ligue um simulador ou emulador e veja o identificador dele:

```bash
flutter emulators                       # lista os simuladores e emuladores instalados
flutter emulators --launch <emulator-id> # liga um deles
flutter devices                         # lista os aparelhos ligados e os ids
```

Nos comandos abaixo, troque `<device-id>` pelo id ou pelo nome que o `flutter devices`
mostrar (por exemplo, `emulator-5554` ou o nome do simulador iOS).

### Testes E2E

O script sobe a API, roda os testes no aparelho e derruba a API no final:

```bash
./scripts/run_e2e.sh -d <device-id>
```

Modo apresentação, com uma pausa entre os passos (em milissegundos):

```bash
E2E_SLOW_MO_MS=700 ./scripts/run_e2e.sh -d <device-id>
```

Sem o script, em dois terminais (funciona em qualquer sistema):

```bash
# terminal 1: sobe a API e deixa rodando
cd server
dart run bin/server.dart

# terminal 2: na raiz do projeto, roda o E2E
flutter test integration_test -d <device-id>
```

Nesse caso, o modo apresentação é ativado com `--dart-define=E2E_SLOW_MO_MS=700`.

### Testes unitários e de widget

Não precisam de aparelho nem da API:

```bash
flutter test                              # todos
flutter test test/application             # só uma pasta
flutter test --name "TasksNotifier"       # só os testes cujo nome contém o texto
```

### Testes da API

```bash
cd server
dart test
```

### Usar o app manualmente

```bash
# terminal 1
cd server
dart run bin/server.dart

# terminal 2, na raiz do projeto
flutter run -d <device-id>
```

Para deixar os loadings visíveis, suba a API com atraso nas respostas:
`LATENCY_MS=800 dart run bin/server.dart` (no PowerShell:
`$env:LATENCY_MS=800; dart run bin/server.dart`).

### Endereço da API

Por padrão, o app usa `http://localhost:8080`. No emulador Android usa
`http://10.0.2.2:8080`, que é como o emulador enxerga o computador. Para outro
endereço, como um aparelho físico na mesma rede, passe o IP do computador:

```bash
flutter test integration_test -d <device-id> --dart-define=API_BASE_URL=http://<ip-do-computador>:8080
flutter run -d <device-id> --dart-define=API_BASE_URL=http://<ip-do-computador>:8080
```

### Problemas comuns

| Sintoma | Causa e solução |
|---|---|
| `Port 8080 is already in use` | Outro processo está usando a porta. Encerre-o e rode de novo. |
| `Demo API unreachable at ...` | A API não está no ar ou o endereço está errado. Suba a API (terminal 1) ou confira o `API_BASE_URL`. |
| `No supported devices connected` | Nenhum aparelho ligado. Veja [Escolher o aparelho](#escolher-o-aparelho). |
| `permission denied: ./scripts/run_e2e.sh` | Dê permissão de execução: `chmod +x scripts/run_e2e.sh`. |

## Arquitetura

Clean Architecture organizada **por camada**. As dependências apontam sempre para
dentro: `presentation → domain ← data`.

```
lib/
├── main.dart                 # ProviderScope + MyApp
├── application/              # estado das telas (notifiers Riverpod)
│   ├── auth/                 # auth_notifier (sessão), login_notifier, register_notifier
│   └── tasks/                # tasks_notifier
├── core/                     # infraestrutura compartilhada
│   ├── network/              # api_config, dio_config, auth_interceptor
│   ├── providers/            # dio_provider, secure_storage_provider
│   └── utils/                # failure, result, error_handler, validators, failure_message
├── data/
│   ├── datasources/          # *_remote_datasource (Dio), secure_storage_datasource
│   ├── models/               # JSON ⇄ entidade
│   └── repositories/         # *_repository_impl
├── domain/
│   ├── entities/             # User, Task
│   ├── repositories/         # contratos
│   └── usecases/             # *_usecase
└── presentation/
    ├── navigation/           # app_routes, app_router (guarda de autenticação)
    ├── pages/                # <tela>/<tela>_page.dart, <tela>_keys.dart, widgets/
    ├── providers/            # <módulo>/<módulo>_provider.dart: injeção de dependências
    ├── theme/                # app_theme
    └── widgets/              # componentes compartilhados (AppButton, AppInput…)
```

| Camada | Responsabilidade | Depende de |
|---|---|---|
| **domain** | Entidades, contratos de repositório e casos de uso. Dart puro. | nada |
| **data** | Fala com a API, converte JSON em entidade e erro HTTP em `Failure`. | domain |
| **application** | Estado das telas: chama os casos de uso e expõe o resultado. | domain |
| **presentation** | Telas, widgets, rotas e a ligação das dependências. | application, domain |

Os imports são sempre `package:app_test_e2e/...` e ficam ordenados. O lint
(`always_use_package_imports` e `directives_ordering`) garante isso.

Decisões que valem destacar:

- **Erros sem exceção:** repositórios e casos de uso retornam `Result<T>`. A tradução
  de erro HTTP para erro de domínio acontece num único lugar
  (`core/utils/error_handler.dart`).
- **A sessão é a fonte da verdade da navegação:** o `GoRouter` escuta o
  `AuthNotifier` e redireciona sozinho no login, no logout e na sessão expirada.
  As regras ficam numa função pura (`resolveRedirect`), testada sem widgets.
- **Atualização otimista:** marcar e excluir tarefas muda a tela na hora e desfaz a
  mudança se a API falhar.
- **Retry automático do Riverpod desligado:** a falha aparece logo e quem decide
  tentar de novo é o usuário. Isso também deixa os testes determinísticos.

Stack: Riverpod 3, Dio, go_router, flutter_secure_storage, equatable e mocktail.

## Estratégia de testes

```
            ▲  E2E (integration_test/)       4 jornadas, app real + API real
           ▲▲▲ Widget (test/presentation)     telas isoladas, repositório mockado
         ▲▲▲▲▲ Unitário (test/, server/test/) regras, mapeamento de erros, rotas
```

O E2E cobre poucas jornadas, mas inteiras. Os detalhes ficam nos níveis de baixo,
que são rápidos e baratos.

### Jornadas do E2E (`integration_test/app_e2e_test.dart`)

1. **Novo usuário:** cadastro → lista vazia → cria 3 tarefas → conclui 1 → exclui 1 →
   sai → entra de novo → as tarefas continuam lá (vieram do servidor).
2. **Sessão persistente:** login → cria tarefa → "fecha e reabre" o app → entra direto,
   sem login.
3. **Senha errada:** mostra o erro e continua na tela de login.
4. **E-mail já cadastrado:** o cadastro mostra o erro vindo da API.

### Boas práticas aplicadas

- **Padrão Robot** (`integration_test/robots/`): o teste descreve *o que* o usuário faz
  (`tasks.addTask('Preparar slides')`), e o robot sabe *como* fazer isso na tela. Se a
  tela mudar, só o robot muda.
- **Keys em vez de texto** (`presentation/pages/<tela>/<tela>_keys.dart`): os widgets e os testes usam as mesmas
  `Key`s. Mudar um texto da tela não quebra o teste.
- **Preparar pela API, agir pela interface:** as pré-condições (por exemplo, um usuário
  já cadastrado) são criadas direto na API. Só o comportamento testado passa pela tela.
- **Testes independentes:** cada teste começa com `POST /test/reset` na API e com o
  token apagado do aparelho, então a ordem de execução não importa.
- **Esperas explícitas:** `pumpUntilFound` espera a resposta real da rede. O
  `pumpAndSettle` sozinho pode seguir antes da requisição terminar.

## API de demonstração (`server/`)

Dart + shelf, com dados em memória (tudo some quando o processo para).

| Método | Rota | Descrição |
|---|---|---|
| `POST` | `/auth/register` | cria a conta e devolve `{token, user}` |
| `POST` | `/auth/login` | devolve `{token, user}` |
| `GET` | `/auth/me` | usuário do token |
| `POST` | `/auth/logout` | invalida o token |
| `GET` `POST` | `/tasks/` | lista e cria tarefas do usuário |
| `PATCH` `DELETE` | `/tasks/<id>` | atualiza e exclui |
| `GET` | `/health` | usado pelo script para esperar a API subir |
| `POST` | `/test/reset` | apaga todos os dados (uso exclusivo dos testes) |

Os erros seguem o formato `{"code": "...", "message": "..."}`, e o app mapeia o `code`
para um `Failure`.
