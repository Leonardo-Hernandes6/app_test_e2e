import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const pageKey = Key('splash.page');

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: pageKey,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
