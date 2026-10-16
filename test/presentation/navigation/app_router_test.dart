import 'package:app_test_e2e/domain/entities/user.dart';
import 'package:app_test_e2e/presentation/navigation/app_router.dart';
import 'package:app_test_e2e/presentation/navigation/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  String? redirect(AsyncValue<User?> session, String location) =>
      resolveRedirect(session: session, location: location);

  test('AppRouter | restaurando a sessão: mantém no splash', () {
    const restoring = AsyncLoading<User?>();

    expect(redirect(restoring, AppRoutes.splash), isNull);
    expect(redirect(restoring, AppRoutes.tasks), AppRoutes.splash);
  });

  test('AppRouter | deslogado: redireciona para o login', () {
    const signedOut = AsyncData<User?>(null);

    expect(redirect(signedOut, AppRoutes.splash), AppRoutes.login);
    expect(redirect(signedOut, AppRoutes.tasks), AppRoutes.login);
    expect(redirect(signedOut, AppRoutes.login), isNull);
    expect(redirect(signedOut, AppRoutes.register), isNull);
  });

  test('AppRouter | logado: pula as telas de login e cadastro', () {
    const signedIn = AsyncData<User?>(ana);

    expect(redirect(signedIn, AppRoutes.splash), AppRoutes.tasks);
    expect(redirect(signedIn, AppRoutes.login), AppRoutes.tasks);
    expect(redirect(signedIn, AppRoutes.register), AppRoutes.tasks);
    expect(redirect(signedIn, AppRoutes.tasks), isNull);
  });
}
