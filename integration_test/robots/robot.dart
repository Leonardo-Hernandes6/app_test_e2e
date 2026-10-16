import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/widget_tester_x.dart';

abstract class Robot {
  const Robot(this.tester);

  final WidgetTester tester;

  static const _slowMo = Duration(
    milliseconds: int.fromEnvironment('E2E_SLOW_MO_MS'),
  );

  @protected
  Future<void> tap(Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    await _pause();
  }

  @protected
  Future<void> type(Key field, String text) async {
    await tester.enterText(find.byKey(field), text);
    await tester.pump();
    await _pause();
  }

  @protected
  Future<void> waitFor(Finder finder) => tester.pumpUntilFound(finder);

  @protected
  Future<void> waitUntilGone(Finder finder) => tester.pumpUntilGone(finder);

  Future<void> _pause() async {
    if (_slowMo == Duration.zero) return;
    await tester.runAsync(() => Future<void>.delayed(_slowMo));
    await tester.pump();
  }
}
