/// فئات الأخطاء المعتمدة في 04-booking-flows.md.
enum FailureCode {
  authRequired,
  forbidden,
  invalidSlot,
  staffUnavailable,
  serviceUnavailable,
  slotTaken,
  cancellationWindowPassed,
  invalidState,
  conflictsWithBookings,
  validation,
  notFound,
  persistenceError,
  responseUnknown,
}

class AppFailure implements Exception {
  const AppFailure(this.code, {this.details});

  final FailureCode code;
  final String? details;

  String get message => switch (code) {
        FailureCode.authRequired => 'يرجى اختيار حساب تجريبي للمتابعة.',
        FailureCode.forbidden => 'ليست لديك صلاحية لهذه العملية.',
        FailureCode.invalidSlot => 'الموعد المختار غير صالح.',
        FailureCode.staffUnavailable => 'الموظف غير متاح لهذه الخدمة.',
        FailureCode.serviceUnavailable => 'الخدمة غير متاحة حالياً.',
        FailureCode.slotTaken => 'تم حجز هذا الموعد، اختر موعداً آخر.',
        FailureCode.cancellationWindowPassed =>
          'انتهت مهلة الإلغاء، يرجى التواصل مع الإدارة.',
        FailureCode.invalidState => 'لا يمكن تنفيذ العملية على حالة الحجز الحالية.',
        FailureCode.conflictsWithBookings =>
          'التغيير يؤثر على حجوزات مؤكدة قادمة.',
        FailureCode.validation => 'البيانات المدخلة غير صحيحة.',
        FailureCode.notFound => 'العنصر المطلوب غير موجود.',
        FailureCode.persistenceError => 'تعذر حفظ البيانات، حاول مرة أخرى.',
        FailureCode.responseUnknown =>
          'لم يتأكد نجاح العملية، جارٍ التحقق قبل إعادة المحاولة.',
      };

  @override
  String toString() => 'AppFailure($code${details == null ? '' : ': $details'})';
}
