import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mawidi/core/clock/clock.dart';
import 'package:mawidi/core/errors/app_failure.dart';
import 'package:mawidi/data/local/demo_seed.dart';
import 'package:mawidi/data/local/demo_storage.dart';
import 'package:mawidi/data/local/local_fake_data_source.dart';
import 'package:mawidi/data/models/models.dart';

void main() {
  late InMemoryDemoStorage storage;
  late FixedClock clock;

  LocalFakeDataSource newSource() =>
      LocalFakeDataSource(storage: storage, clock: clock);

  Future<LocalFakeDataSource> loaded() async {
    final source = newSource();
    await source.init();
    return source;
  }

  Future<void> renameCustomerA(LocalFakeDataSource source, String name) =>
      source.mutate((s) {
        final i = s.profiles.indexWhere((p) => p.id == DemoSeed.customerA);
        s.profiles[i] = s.profiles[i].copyWith(fullName: name);
      });

  Future<String> customerAName(LocalFakeDataSource source) =>
      source.read((s) => s.profileById(DemoSeed.customerA)!.fullName);

  setUp(() {
    storage = InMemoryDemoStorage();
    clock = FixedClock(DateTime.utc(2026, 11, 1, 6));
  });

  test('أول تشغيل يحمل seed: 2 زبون، 4 موظفين، مدير، SYP', () async {
    final source = await loaded();
    final counts = await source.read((s) => {
          for (final role in UserRole.values)
            role: s.profiles.where((p) => p.role == role).length,
        });
    expect(counts, {UserRole.customer: 2, UserRole.staff: 4, UserRole.admin: 1});
    final currencies = await source.read((s) => s.services.map((e) => e.currencyCode).toSet());
    expect(currencies, {'SYP'});
    expect(storage.values.containsKey(LocalFakeDataSource.dataKey), isTrue);
  });

  test('التعديلات والجلسة تستمر بعد إعادة التشغيل (AC-DEMO-02)', () async {
    final first = await loaded();
    await renameCustomerA(first, 'اسم جديد');
    await first.setSession(DemoSeed.customerA);

    final restarted = await loaded();
    expect(await customerAName(restarted), 'اسم جديد');
    expect(restarted.sessionAccountId, DemoSeed.customerA);
  });

  test('إعادة الضبط تعيد seed وتمسح الجلسة (AC-DEMO-03)', () async {
    final source = await loaded();
    await renameCustomerA(source, 'اسم جديد');
    await source.setSession(DemoSeed.admin);

    await source.resetDemoData();
    expect(await customerAName(source), 'سارة الزبونة');
    expect(source.sessionAccountId, isNull);

    final restarted = await loaded();
    expect(restarted.sessionAccountId, isNull);
    expect(await customerAName(restarted), 'سارة الزبونة');
  });

  test('فشل الكتابة لا يترك تحديثاً جزئياً (AC-DEMO-06)', () async {
    final source = await loaded();
    source.faults.failNextWrite = true;
    await expectLater(
      renameCustomerA(source, 'لن يحفظ'),
      throwsA(isA<AppFailure>().having((f) => f.code, 'code', FailureCode.persistenceError)),
    );
    expect(await customerAName(source), 'سارة الزبونة');
    expect(await customerAName(await loaded()), 'سارة الزبونة');
  });

  test('فقد الرد بعد الحفظ: التعديل محفوظ مع RESPONSE_UNKNOWN', () async {
    final source = await loaded();
    source.faults.loseNextResponse = true;
    await expectLater(
      renameCustomerA(source, 'محفوظ'),
      throwsA(isA<AppFailure>().having((f) => f.code, 'code', FailureCode.responseUnknown)),
    );
    expect(await customerAName(source), 'محفوظ');
  });

  test('فشل القراءة المحاكى ثم نجاح إعادة المحاولة', () async {
    final source = await loaded();
    source.faults.failNextRead = true;
    await expectLater(customerAName(source), throwsA(isA<AppFailure>()));
    expect(await customerAName(source), 'سارة الزبونة');
  });

  test('البيانات التالفة لا تستبدل بصمت', () async {
    storage.values[LocalFakeDataSource.dataKey] = '{"version":99}';
    final source = newSource();
    await expectLater(source.init(), throwsA(isA<AppFailure>()));
    expect(storage.values[LocalFakeDataSource.dataKey], '{"version":99}');

    await source.resetDemoData();
    expect(await customerAName(source), 'سارة الزبونة');
  });

  test('القراءة تعمل على نسخة لا تعدل الحالة', () async {
    final source = await loaded();
    await source.read((s) => s.profiles.clear());
    expect(await source.read((s) => s.profiles.length), 7);
  });

  test('التعديلات المتزامنة متسلسلة ولا تفقد تحديثاً', () async {
    final source = await loaded();
    await Future.wait([
      for (var i = 0; i < 10; i++) source.mutate((s) => s.newId('x')),
    ]);
    expect(await source.read((s) => s.nextId), 11);
    final saved = jsonDecode(storage.values[LocalFakeDataSource.dataKey]!) as Map;
    expect(saved['next_id'], 11);
  });

  test('جلسة لحساب غير موجود تزال عند التحميل', () async {
    await loaded();
    storage.values[LocalFakeDataSource.sessionKey] = 'missing';
    final source = await loaded();
    expect(source.sessionAccountId, isNull);
  });
}
