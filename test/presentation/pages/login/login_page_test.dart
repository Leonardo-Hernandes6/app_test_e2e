import 'package:app_test_e2e/core/utils/failure.dart';
import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/domain/repositories/auth_repository.dart';
import 'package:app_test_e2e/presentation/pages/login/login_keys.dart';
import 'package:app_test_e2e/presentation/pages/login/login_page.dart';
import 'package:app_test_e2e/presentation/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;

  setUp(() {
    repository = _MockAuthRepository();
    when(repository.restoreSession).thenAnswer((_) async => const Ok(null));
  });

  Future<void> pumpPage(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      retry: (_, _) => null,
      child: const MaterialApp(home: LoginPage()),
    ),
  );

  testWidgets('LoginPage | valida os campos antes de chamar a API', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.enterText(find.byKey(LoginKeys.email), 'not-an-email');
    await tester.tap(find.byKey(LoginKeys.submit));
    await tester.pump();

    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    expect(find.text('Informe sua senha.'), findsOneWidget);
    verifyNever(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('LoginPage | mostra o erro da API no banner', (tester) async {
    when(
      () => repository.login(email: 'ana@demo.com', password: 'errada'),
    ).thenAnswer((_) async => const Err(InvalidCredentialsFailure()));
    await pumpPage(tester);

    await tester.enterText(find.byKey(LoginKeys.email), ' Ana@Demo.com ');
    await tester.enterText(find.byKey(LoginKeys.password), 'errada');
    await tester.tap(find.byKey(LoginKeys.submit));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(LoginKeys.error),
        matching: find.text('E-mail ou senha incorretos.'),
      ),
      findsOneWidget,
    );
  });
}
