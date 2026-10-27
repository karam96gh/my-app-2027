/// مصدر الوقت القابل للحقن (NFR-05). كل اللحظات المعادة بتوقيت UTC.
abstract class Clock {
  DateTime now();
}

/// ساعة الجهاز؛ مقبولة للتجربة فقط وغير موثوقة للإنتاج.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

/// ساعة ثابتة قابلة للتحريك للاختبارات.
class FixedClock implements Clock {
  FixedClock(DateTime instant) : _now = instant.toUtc();

  DateTime _now;

  @override
  DateTime now() => _now;

  void set(DateTime instant) => _now = instant.toUtc();

  void advance(Duration duration) => _now = _now.add(duration);
}
