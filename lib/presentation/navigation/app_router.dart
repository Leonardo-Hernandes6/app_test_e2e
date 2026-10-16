import 'package:app_test_e2e/domain/entities/user.dart';
import 'package:app_test_e2e/presentation/navigation/app_routes.dart';
import 'package:app_test_e2e/presentation/pages/login/login_page.dart';
import 'package:app_test_e2e/presentation/pages/register/register_page.dart';
import 'package:app_test_e2e/presentation/pages/splash/splash_page.dart';
import 'package:app_test_e2e/presentation/pages/tasks/tasks_page.dart';
import 'package:app_test_e2e/presentation/providers/auth/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier<AsyncValue<User?>>(const AsyncLoading());
  ref
    ..listen(
      authNotifierProvider,
      (_, next) => session.value = next,
      fireImmediately: true,
    )
    ..onDispose(session.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: session,
    redirect: (_, state) => resolveRedirect(
      session: session.value,
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterPage(),
      ),
      GoRoute(path: AppRoutes.tasks, builder: (_, _) => const TasksPage()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

@visibleForTesting
String? resolveRedirect({
  required AsyncValue<User?> session,
  required String location,
}) {
  if (!session.hasValue) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  final signedIn = session.value != null;
  final onAuthScreen =
      location == AppRoutes.login || location == AppRoutes.register;

  if (!signedIn) return onAuthScreen ? null : AppRoutes.login;
  if (onAuthScreen || location == AppRoutes.splash) return AppRoutes.tasks;
  return null;
}
