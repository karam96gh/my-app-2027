import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mawidi/app/app.dart';
import 'package:mawidi/core/clock/clock.dart';
import 'package:mawidi/core/time/center_time.dart';

void main() {
  setUpAll(CenterTime.ensureInitialized);
  tearDown(Get.reset);

  testWidgets('التطبيق يبدأ بالعربية وRTL ووقت المركز', (tester) async {
    final clock = FixedClock(CenterTime.localToUtc(2026, 11, 1, 14, 5));
    await tester.pumpWidget(MawidiApp(clock: clock));
    await tester.pumpAndSettle();

    expect(find.text('موعدي'), findsOneWidget);
    expect(find.text('وقت المركز: 2026-11-01 14:05'), findsOneWidget);
    final context = tester.element(find.byType(Scaffold));
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
