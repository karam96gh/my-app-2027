import 'package:get/get.dart';

import '../core/clock/clock.dart';
import '../data/local/local_fake_data_source.dart';
import '../features/home/home_view.dart';
import '../features/home/home_view_model.dart';

abstract class AppRoutes {
  static const home = '/';
}

final appPages = [
  GetPage(
    name: AppRoutes.home,
    page: () => const HomeView(),
    binding: BindingsBuilder(
      () => Get.lazyPut(
          () => HomeViewModel(Get.find<Clock>(), Get.find<LocalFakeDataSource>())),
    ),
  ),
];
