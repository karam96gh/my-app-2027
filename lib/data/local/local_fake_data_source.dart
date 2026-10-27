import 'dart:async';
import 'dart:convert';

import '../../core/clock/clock.dart';
import '../../core/errors/app_failure.dart';
import '../models/models.dart';
import 'demo_seed.dart';
import 'demo_state.dart';
import 'demo_storage.dart';

/// أدوات محاكاة الأعطال (02: تأخير وفشل القراءة والكتابة وفقد الرد).
class FaultInjector {
  Duration readDelay = Duration.zero;
  bool failNextRead = false;
  bool failNextWrite = false;
  bool loseNextResponse = false;

  void clear() {
    readDelay = Duration.zero;
    failNextRead = failNextWrite = loseNextResponse = false;
  }
}

/// المصدر الوهمي المحلي: تحميل/حفظ مستمر، تسلسل التعديلات، إعادة ضبط صريحة.
class LocalFakeDataSource {
  LocalFakeDataSource({
    required DemoStorage storage,
    required this.clock,
    FaultInjector? faults,
  })  : _storage = storage,
        faults = faults ?? FaultInjector();

  static const dataKey = 'mawidi.demo.data';
  static const sessionKey = 'mawidi.demo.session';

  final DemoStorage _storage;
  final Clock clock;
  final FaultInjector faults;

  DemoState? _state;
  String? _sessionAccountId;
  Future<void> _queue = Future.value();

  bool get isLoaded => _state != null;

  /// يحمل النسخة المحفوظة أو seed عند أول تشغيل فقط.
  /// البيانات التالفة لا تستبدل بصمت: يرمى PERSISTENCE_ERROR ويبقى reset متاحاً.
  Future<void> init() => _serialized(() async {
        final raw = await _storage.read(dataKey);
        if (raw == null) {
          final seeded = DemoSeed.build(clock.now());
          await _persist(seeded);
          _state = seeded;
        } else {
          try {
            _state = DemoState.fromJson(
                (jsonDecode(raw) as Map).cast<String, Object?>());
          } catch (e) {
            throw AppFailure(FailureCode.persistenceError, details: '$e');
          }
        }
        _sessionAccountId = await _storage.read(sessionKey);
        if (_sessionAccountId != null &&
            !_state!.accounts.any((a) => a.id == _sessionAccountId)) {
          _sessionAccountId = null;
          await _storage.delete(sessionKey);
        }
      });

  String? get sessionAccountId => _sessionAccountId;

  Future<void> setSession(String? accountId) => _serialized(() async {
        _requireState();
        try {
          if (accountId == null) {
            await _storage.delete(sessionKey);
          } else {
            await _storage.write(sessionKey, accountId);
          }
        } catch (e) {
          throw AppFailure(FailureCode.persistenceError, details: '$e');
        }
        _sessionAccountId = accountId;
      });

  /// قراءة على لقطة منسوخة؛ لا تسمح بتعديل الحالة خارج mutate.
  Future<T> read<T>(T Function(DemoState state) reader) =>
      _serialized(() async {
        if (faults.readDelay > Duration.zero) {
          await Future<void>.delayed(faults.readDelay);
        }
        if (faults.failNextRead) {
          faults.failNextRead = false;
          throw const AppFailure(FailureCode.persistenceError,
              details: 'simulated read failure');
        }
        return reader(_requireState().copy());
      });

  /// تحقق وتعديل وحفظ متسلسل داخل المثيل. لا نجاح قبل اكتمال الحفظ،
  /// وفشل الحفظ يبقي الحالة السابقة دون تحديث جزئي.
  Future<T> mutate<T>(T Function(DemoState draft) action) =>
      _serialized(() async {
        final draft = _requireState().copy();
        final result = action(draft);
        if (faults.failNextWrite) {
          faults.failNextWrite = false;
          throw const AppFailure(FailureCode.persistenceError,
              details: 'simulated write failure');
        }
        await _persist(draft);
        _state = draft;
        if (faults.loseNextResponse) {
          faults.loseNextResponse = false;
          throw const AppFailure(FailureCode.responseUnknown);
        }
        return result;
      });

  /// إعادة ضبط صريحة: seed جديد ومسح الجلسة (D-09).
  Future<void> resetDemoData() => _serialized(() async {
        final seeded = DemoSeed.build(clock.now());
        await _persist(seeded);
        try {
          await _storage.delete(sessionKey);
        } catch (e) {
          throw AppFailure(FailureCode.persistenceError, details: '$e');
        }
        _state = seeded;
        _sessionAccountId = null;
      });

  Future<void> _persist(DemoState state) async {
    try {
      await _storage.write(dataKey, jsonEncode(state.toJson()));
    } catch (e) {
      throw AppFailure(FailureCode.persistenceError, details: '$e');
    }
  }

  DemoState _requireState() {
    final state = _state;
    if (state == null) {
      throw const AppFailure(FailureCode.persistenceError,
          details: 'data source not loaded');
    }
    return state;
  }

  Future<T> _serialized<T>(Future<T> Function() task) {
    final completer = Completer<T>();
    _queue = _queue.then((_) async {
      try {
        completer.complete(await task());
      } catch (e, s) {
        completer.completeError(e, s);
      }
    });
    return completer.future;
  }
}

extension DemoStateLookup on DemoState {
  Profile? profileById(String id) =>
      profiles.where((p) => p.id == id).firstOrNull;
}
