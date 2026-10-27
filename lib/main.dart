import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/time/center_time.dart';

void main() {
  CenterTime.ensureInitialized();
  runApp(const MawidiApp());
}
