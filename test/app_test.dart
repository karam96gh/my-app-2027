import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mawidi/app/app.dart';
import 'package:mawidi/core/clock/clock.dart';
import 'package:mawidi/core/time/center_time.dart';
import 'package:mawidi/data/local/demo_storage.dart';
import 'package:mawidi/data/local/local_fake_data_source.dart';

void main() {
  setUpAll(CenterTime.ensureInitialized);
  tearDown(Get.reset);

  Future<LocalFakeDataSource> pumpApp(WidgetTester tester,
      {FaultInjector? faults}) async {
    final clock = FixedClock(CenterTime.localToUtc(2026, 11, 1, 14, 5));
    final source = LocalFakeDataSource(
        storage: InMemoryDemoStorage(), clock: clock, faults: faults);
    await tester.pumpWidget(MawidiApp(clock: clock, dataSource: source));
    await tester.pumpAndSettle();
    return source;
  }

  testWidgets('التطبيق يبدأ بالعربية وRTL ووقت المركز ويحمل seed',
      (tester) async {
    await pumpApp(tester);

    expect(find.text('موعدي'), findsOneWidget);
    expect(find.text('وقت المركز: 2026-11-01 14:05'), findsOneWidget);
    expect(find.textContaining('الحسابات: 7'), findsOneWidget);
    final context = tester.element(find.byType(Scaffold));
    expect(Directionality.of(context), TextDirection.rtl);
  });

  testWidgets('فشل القراءة يعرض خطأ وإعادة محاولة (AC-UX-02)', (tester) async {
    final faults = FaultInjector()..failNextRead = true;
    await pumpApp(tester, faults: faults);

    expect(find.text('تعذر حفظ البيانات، حاول مرة أخرى.'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(find.textContaining('الحسابات: 7'), findsOneWidget);
  });
}
