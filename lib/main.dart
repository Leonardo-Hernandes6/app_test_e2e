import 'package:app_test_e2e/presentation/navigation/app_router.dart';
import 'package:app_test_e2e/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

void main() => runApp(createApp());

Widget createApp({List<Override> overrides = const []}) => ProviderScope(
  overrides: overrides,
  retry: (_, _) => null,
  child: const MyApp(),
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Tarefas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
