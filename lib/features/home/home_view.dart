import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_view_model.dart';

class HomeView extends GetView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('موعدي')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('النسخة التجريبية المحلية'),
              const SizedBox(height: 8),
              Obx(() => Text('وقت المركز: ${controller.centerNow.value}')),
            ],
          ),
        ),
      ),
    );
  }
}
