import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig({required this.apiBaseUrl});

  factory ApiConfig.fromEnvironment() {
    const fromEnvironment = String.fromEnvironment('API_BASE_URL');
    if (fromEnvironment.isNotEmpty) {
      return const ApiConfig(apiBaseUrl: fromEnvironment);
    }
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    return ApiConfig(
      apiBaseUrl: 'http://${isAndroid ? '10.0.2.2' : 'localhost'}:8080',
    );
  }

  final String apiBaseUrl;
}
