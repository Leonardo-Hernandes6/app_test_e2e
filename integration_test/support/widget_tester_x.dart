import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterWaits on WidgetTester {
  static const _defaultTimeout = Duration(seconds: 10);
  static const _interval = Duration(milliseconds: 100);

  Future<void> pumpUntilFound(
    Finder finder, {
    Duration timeout = _defaultTimeout,
  }) => _pumpUntil(
    () => finder.evaluate().isNotEmpty,
    timeout,
    'Timed out waiting for $finder',
  );

  Future<void> pumpUntilGone(
    Finder finder, {
    Duration timeout = _defaultTimeout,
  }) => _pumpUntil(
    () => finder.evaluate().isEmpty,
    timeout,
    'Timed out waiting for $finder to disappear',
  );

  Future<void> _pumpUntil(
    bool Function() condition,
    Duration timeout,
    String reason,
  ) async {
    final deadline = DateTime.now().add(timeout);
    while (!condition()) {
      if (DateTime.now().isAfter(deadline)) throw TestFailure(reason);
      await pump(_interval);
    }
    await pumpAndSettle();
  }
}
