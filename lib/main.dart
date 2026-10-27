import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/clock/clock.dart';
import 'core/time/center_time.dart';
import 'data/local/demo_storage.dart';
import 'data/local/local_fake_data_source.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  CenterTime.ensureInitialized();
  const clock = SystemClock();
  runApp(MawidiApp(
    clock: clock,
    dataSource: LocalFakeDataSource(
      storage: SharedPrefsDemoStorage(),
      clock: clock,
    ),
  ));
}
