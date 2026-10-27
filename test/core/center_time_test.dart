import 'package:flutter_test/flutter_test.dart';
import 'package:mawidi/core/clock/clock.dart';
import 'package:mawidi/core/time/center_time.dart';

void main() {
  setUpAll(CenterTime.ensureInitialized);

  test('FixedClock يعيد UTC ويتقدم', () {
    final clock = FixedClock(DateTime.utc(2026, 11, 1, 6));
    expect(clock.now().isUtc, isTrue);
    clock.advance(const Duration(hours: 2));
    expect(clock.now(), DateTime.utc(2026, 11, 1, 8));
  });

  test('تحويل وقت المركز ذهاباً وإياباً دون فقد اللحظة', () {
    final utc = CenterTime.localToUtc(2026, 11, 1, 9, 30);
    expect(utc.isUtc, isTrue);
    expect(CenterTime.formatTime(utc), '09:30');
    expect(CenterTime.formatDate(utc), '2026-11-01');
  });

  test('منتصف الليل المحلي يبقى في يومه المحلي', () {
    final utc = CenterTime.localToUtc(2026, 11, 2);
    expect(CenterTime.formatDate(utc), '2026-11-02');
    expect(CenterTime.formatTime(utc), '00:00');
  });
}
