import '../models/models.dart';

/// لقطة كاملة لبيانات التجربة؛ تنسخ قبل كل تعديل لضمان عدم الكتابة الجزئية.
class DemoState {
  DemoState({
    required this.accounts,
    required this.profiles,
    required this.staff,
    required this.services,
    required this.staffServices,
    required this.workingHours,
    required this.timeOff,
    required this.bookings,
    required this.nextId,
  });

  static const formatVersion = 1;

  final List<DemoAccount> accounts;
  final List<Profile> profiles;
  final List<StaffProfile> staff;
  final List<Service> services;
  final List<StaffService> staffServices;
  final List<WorkingHours> workingHours;
  final List<StaffTimeOff> timeOff;
  final List<Booking> bookings;

  /// عداد المعرفات المحلية الفريدة.
  int nextId;

  String newId(String prefix) => '$prefix-${nextId++}';

  DemoState copy() => DemoState.fromJson(toJson());

  Map<String, Object?> toJson() => {
        'version': formatVersion,
        'next_id': nextId,
        'accounts': [for (final e in accounts) e.toJson()],
        'profiles': [for (final e in profiles) e.toJson()],
        'staff': [for (final e in staff) e.toJson()],
        'services': [for (final e in services) e.toJson()],
        'staff_services': [for (final e in staffServices) e.toJson()],
        'working_hours': [for (final e in workingHours) e.toJson()],
        'time_off': [for (final e in timeOff) e.toJson()],
        'bookings': [for (final e in bookings) e.toJson()],
      };

  /// يرمي FormatException عند إصدار غير مدعوم أو بنية تالفة.
  factory DemoState.fromJson(Map<String, Object?> json) {
    if (json['version'] != formatVersion) {
      throw FormatException('Unsupported demo data version: ${json['version']}');
    }
    List<T> list<T>(String key, T Function(Map<String, Object?>) parse) => [
          for (final item in json[key] as List)
            parse((item as Map).cast<String, Object?>()),
        ];
    return DemoState(
      nextId: json['next_id'] as int,
      accounts: list('accounts', DemoAccount.fromJson),
      profiles: list('profiles', Profile.fromJson),
      staff: list('staff', StaffProfile.fromJson),
      services: list('services', Service.fromJson),
      staffServices: list('staff_services', StaffService.fromJson),
      workingHours: list('working_hours', WorkingHours.fromJson),
      timeOff: list('time_off', StaffTimeOff.fromJson),
      bookings: list('bookings', Booking.fromJson),
    );
  }
}
