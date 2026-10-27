import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import '../core/clock/clock.dart';
import 'app_routes.dart';

class MawidiApp extends StatelessWidget {
  const MawidiApp({super.key, this.clock = const SystemClock()});

  final Clock clock;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'موعدي',
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() => Get.put<Clock>(clock)),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      getPages: appPages,
    );
  }
}
