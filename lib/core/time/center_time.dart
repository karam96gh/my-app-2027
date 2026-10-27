import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// توقيت المركز وفق IANA دون إزاحة ثابتة (D-02).
class CenterTime {
  CenterTime._();

  static const zoneName = 'Asia/Damascus';

  static bool _initialized = false;

  static void ensureInitialized() {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    _initialized = true;
  }

  static tz.Location get location {
    ensureInitialized();
    return tz.getLocation(zoneName);
  }

  /// يحول لحظة UTC إلى وقت المركز للعرض والحساب.
  static tz.TZDateTime toLocal(DateTime instant) =>
      tz.TZDateTime.from(instant.toUtc(), location);

  /// يبني وقتاً محلياً للمركز ويعيده لحظة UTC.
  static DateTime localToUtc(int year, int month, int day,
          [int hour = 0, int minute = 0]) =>
      tz.TZDateTime(location, year, month, day, hour, minute).toUtc();

  static String formatTime(DateTime instant) {
    final local = toLocal(instant);
    return '${_two(local.hour)}:${_two(local.minute)}';
  }

  static String formatDate(DateTime instant) {
    final local = toLocal(instant);
    return '${local.year}-${_two(local.month)}-${_two(local.day)}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
