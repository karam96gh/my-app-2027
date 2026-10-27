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
          child: Obx(() {
            if (controller.isBusy.value) {
              return const CircularProgressIndicator();
            }
            final error = controller.error.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('النسخة التجريبية المحلية'),
                const SizedBox(height: 8),
                Text('وقت المركز: ${controller.centerNow.value}'),
                const SizedBox(height: 8),
                if (error != null) ...[
                  Text(error,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                  TextButton(
                    onPressed: controller.load,
                    child: const Text('إعادة المحاولة'),
                  ),
                ] else
                  Text(controller.summary.value),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => _confirmReset(context),
                  child: const Text('إعادة ضبط بيانات التجربة'),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة ضبط التجربة'),
        content: const Text(
            'ستعاد البيانات الأولية وتمسح الجلسة الحالية. هل تريد المتابعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إعادة الضبط'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.resetDemo();
  }
}
