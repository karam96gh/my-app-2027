import 'package:get/get.dart';

import '../../core/clock/clock.dart';
import '../../core/time/center_time.dart';

class HomeViewModel extends GetxController {
  HomeViewModel(this._clock);

  final Clock _clock;

  final centerNow = ''.obs;

  @override
  void onInit() {
    super.onInit();
    refreshTime();
  }

  void refreshTime() {
    final now = _clock.now();
    centerNow.value =
        '${CenterTime.formatDate(now)} ${CenterTime.formatTime(now)}';
  }
}
