import 'package:app_test_e2e/core/utils/result.dart';
import 'package:app_test_e2e/domain/entities/user.dart';
import 'package:app_test_e2e/presentation/providers/auth/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AuthFormNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  @protected
  Future<void> submit(Future<Result<User>> Function() action) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final result = await action();
    if (!ref.mounted) return;

    switch (result) {
      case Ok(:final value):
        state = const AsyncData(null);
        ref.read(authNotifierProvider.notifier).signedIn(value);
      case Err(:final failure):
        state = AsyncError(failure, StackTrace.current);
    }
  }
}
