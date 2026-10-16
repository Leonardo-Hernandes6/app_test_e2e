import 'package:app_test_e2e/data/datasources/secure_storage_datasource.dart';
import 'package:app_test_e2e/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'robots/login_robot.dart';
import 'robots/register_robot.dart';
import 'robots/tasks_robot.dart';
import 'support/e2e_backend.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final backend = E2EBackend();

  const name = 'Ana Souza';
  const email = 'ana@demo.com';
  const password = 'senha-segura';

  setUpAll(backend.ensureReachable);

  setUp(() async {
    await backend.reset();
    await const SecureStorageDatasourceImpl().clear();
  });

  Future<void> launchApp(WidgetTester tester) async {
    await tester.pumpWidget(createApp());
    await tester.pumpAndSettle();
  }

  Future<void> relaunchApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await launchApp(tester);
  }

  testWidgets(
    'E2E-01 | Cadastro: novo usuário cria a conta, gerencia tarefas, sai e entra de novo',
    (tester) async {
      final login = LoginRobot(tester);
      final register = RegisterRobot(tester);
      final tasks = TasksRobot(tester);

      await launchApp(tester);

      // Abre o cadastro a partir do login e cria a conta
      await login.expectVisible();
      await login.openRegister();
      await register.expectVisible();
      await register.register(name: name, email: email, password: password);

      // Entra logado, com a lista vazia
      await tasks.expectVisible(greeting: 'Olá, Ana');
      await tasks.expectEmpty();

      // Cria 3 tarefas
      await tasks.addTask('Preparar slides');
      await tasks.addTask('Ensaiar a demo');
      await tasks.addTask('Comprar café');
      tasks.expectSummary('0 de 3 concluídas');

      // Conclui 1 tarefa
      await tasks.toggleTask('Preparar slides');
      await tasks.expectTask('Preparar slides', done: true);
      tasks.expectSummary('1 de 3 concluídas');

      // Exclui 1 tarefa
      await tasks.deleteTask('Comprar café');
      tasks.expectSummary('1 de 2 concluídas');

      // Sai e entra de novo com o mesmo usuário
      await tasks.logout();
      await login.expectVisible();
      await login.login(email: email, password: password);

      // As tarefas voltam como foram deixadas
      await tasks.expectVisible(greeting: 'Olá, Ana');
      await tasks.expectTask('Preparar slides', done: true);
      await tasks.expectTask('Ensaiar a demo', done: false);
      tasks.expectNoTask('Comprar café');
    },
  );

  testWidgets(
    'E2E-02 | Sessão: usuário continua logado depois de fechar e reabrir o app',
    (tester) async {
      // Usuário já cadastrado direto na API
      await backend.registerUser(name: name, email: email, password: password);
      final login = LoginRobot(tester);
      final tasks = TasksRobot(tester);

      // Faz login e cria uma tarefa
      await launchApp(tester);
      await login.login(email: email, password: password);
      await tasks.expectVisible(greeting: 'Olá, Ana');
      await tasks.addTask('Revisar roteiro');

      // Fecha e reabre o app
      await relaunchApp(tester);

      // Abre direto nas tarefas, sem passar pelo login
      await tasks.expectVisible(greeting: 'Olá, Ana');
      await tasks.expectTask('Revisar roteiro', done: false);
    },
  );

  testWidgets(
    'E2E-03 | Login: senha errada mostra erro e mantém o usuário no login',
    (tester) async {
      // Usuário já cadastrado direto na API
      await backend.registerUser(name: name, email: email, password: password);
      final login = LoginRobot(tester);

      // Tenta entrar com a senha errada
      await launchApp(tester);
      await login.login(email: email, password: 'senha-errada');

      // Mostra o erro e continua na tela de login
      await login.expectError('E-mail ou senha incorretos.');
      await login.expectVisible();
    },
  );

  testWidgets('E2E-04 | Cadastro: e-mail já cadastrado mostra erro', (
    tester,
  ) async {
    // Usuário já cadastrado direto na API
    await backend.registerUser(name: name, email: email, password: password);
    final login = LoginRobot(tester);
    final register = RegisterRobot(tester);

    // Tenta criar outra conta com o mesmo e-mail
    await launchApp(tester);
    await login.openRegister();
    await register.register(
      name: 'Outra Ana',
      email: email,
      password: password,
    );

    // Mostra o erro na tela de cadastro
    await register.expectError('Já existe uma conta com este e-mail.');
  });
}
