import 'package:get/get.dart';

import '../../core/clock/clock.dart';
import '../../core/errors/app_failure.dart';
import '../../core/time/center_time.dart';
import '../../data/local/local_fake_data_source.dart';

class HomeViewModel extends GetxController {
  HomeViewModel(this._clock, this._source);

  final Clock _clock;
  final LocalFakeDataSource _source;

  final centerNow = ''.obs;
  final isBusy = false.obs;
  final error = RxnString();
  final summary = ''.obs;

  @override
  void onInit() {
    super.onInit();
    refreshTime();
    load();
  }

  void refreshTime() {
    final now = _clock.now();
    centerNow.value =
        '${CenterTime.formatDate(now)} ${CenterTime.formatTime(now)}';
  }

  Future<void> load() => _run(() async {
        if (!_source.isLoaded) await _source.init();
        summary.value = await _source.read((s) =>
            'الحسابات: ${s.accounts.length} • الخدمات: ${s.services.length} • الحجوزات: ${s.bookings.length}');
      });

  Future<void> resetDemo() => _run(() async {
        await _source.resetDemoData();
        await load();
      });

  Future<void> _run(Future<void> Function() task) async {
    isBusy.value = true;
    error.value = null;
    try {
      await task();
    } on AppFailure catch (f) {
      error.value = f.message;
    } finally {
      isBusy.value = false;
    }
  }
}
