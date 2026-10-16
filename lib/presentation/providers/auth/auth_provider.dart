import 'package:app_test_e2e/application/auth/auth_notifier.dart';
import 'package:app_test_e2e/application/auth/login_notifier.dart';
import 'package:app_test_e2e/application/auth/register_notifier.dart';
import 'package:app_test_e2e/core/providers/dio_provider.dart';
import 'package:app_test_e2e/core/providers/secure_storage_provider.dart';
import 'package:app_test_e2e/data/datasources/auth_remote_datasource.dart';
import 'package:app_test_e2e/data/repositories/auth_repository_impl.dart';
import 'package:app_test_e2e/domain/entities/user.dart';
import 'package:app_test_e2e/domain/repositories/auth_repository.dart';
import 'package:app_test_e2e/domain/usecases/login_usecase.dart';
import 'package:app_test_e2e/domain/usecases/logout_usecase.dart';
import 'package:app_test_e2e/domain/usecases/register_usecase.dart';
import 'package:app_test_e2e/domain/usecases/restore_session_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasourceImpl(ref.watch(dioProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remote: ref.watch(authRemoteDatasourceProvider),
    secureStorage: ref.watch(secureStorageDatasourceProvider),
  ),
);

final loginUsecaseProvider = Provider(
  (ref) => LoginUsecase(ref.watch(authRepositoryProvider)),
);

final registerUsecaseProvider = Provider(
  (ref) => RegisterUsecase(ref.watch(authRepositoryProvider)),
);

final logoutUsecaseProvider = Provider(
  (ref) => LogoutUsecase(ref.watch(authRepositoryProvider)),
);

final restoreSessionUsecaseProvider = Provider(
  (ref) => RestoreSessionUsecase(ref.watch(authRepositoryProvider)),
);

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

final loginNotifierProvider =
    NotifierProvider.autoDispose<LoginNotifier, AsyncValue<void>>(
      LoginNotifier.new,
    );

final registerNotifierProvider =
    NotifierProvider.autoDispose<RegisterNotifier, AsyncValue<void>>(
      RegisterNotifier.new,
    );
