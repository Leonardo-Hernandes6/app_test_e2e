import 'package:app_test_e2e/data/datasources/secure_storage_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageDatasourceProvider = Provider<SecureStorageDatasource>(
  (ref) => const SecureStorageDatasourceImpl(),
);
