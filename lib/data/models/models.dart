// نماذج 01-entities.md. اللحظات UTC، والأموال بوحدات صغرى صحيحة (قرش = 1/100).

enum UserRole { customer, staff, admin }

enum BookingStatus { confirmed, cancelled, completed }

DateTime _instant(Object? value) => DateTime.parse(value as String).toUtc();
DateTime? _optionalInstant(Object? value) =>
    value == null ? null : _instant(value);

class DemoAccount {
  const DemoAccount({required this.id, required this.displayName});

  /// مطابق لمعرف Profile.
  final String id;
  final String displayName;

  Map<String, Object?> toJson() => {'id': id, 'display_name': displayName};

  factory DemoAccount.fromJson(Map<String, Object?> json) => DemoAccount(
        id: json['id'] as String,
        displayName: json['display_name'] as String,
      );
}

class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final UserRole role;
  final DateTime createdAt;

  Profile copyWith({String? fullName}) => Profile(
        id: id,
        fullName: fullName ?? this.fullName,
        role: role,
        createdAt: createdAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'full_name': fullName,
        'role': role.name,
        'created_at': createdAt.toIso8601String(),
      };

  factory Profile.fromJson(Map<String, Object?> json) => Profile(
        id: json['id'] as String,
        fullName: json['full_name'] as String,
        role: UserRole.values.byName(json['role'] as String),
        createdAt: _instant(json['created_at']),
      );
}

class StaffProfile {
  const StaffProfile({
    required this.id,
    required this.userId,
    required this.isActive,
  });

  final String id;
  final String userId;
  final bool isActive;

  StaffProfile copyWith({bool? isActive}) => StaffProfile(
        id: id,
        userId: userId,
        isActive: isActive ?? this.isActive,
      );

  Map<String, Object?> toJson() =>
      {'id': id, 'user_id': userId, 'is_active': isActive};

  factory StaffProfile.fromJson(Map<String, Object?> json) => StaffProfile(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        isActive: json['is_active'] as bool,
      );
}

class Service {
  const Service({
    required this.id,
    required this.name,
    required this.priceMinor,
    required this.isActive,
    this.currencyCode = sypCode,
  });

  static const sypCode = 'SYP';

  final String id;
  final String name;

  /// السعر بالقروش لتجنب أخطاء الكسور العائمة.
  final int priceMinor;
  final String currencyCode;
  final bool isActive;

  Service copyWith({String? name, int? priceMinor, bool? isActive}) => Service(
        id: id,
        name: name ?? this.name,
        priceMinor: priceMinor ?? this.priceMinor,
        isActive: isActive ?? this.isActive,
        currencyCode: currencyCode,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'price_minor': priceMinor,
        'currency_code': currencyCode,
        'is_active': isActive,
      };

  factory Service.fromJson(Map<String, Object?> json) => Service(
        id: json['id'] as String,
        name: json['name'] as String,
        priceMinor: json['price_minor'] as int,
        currencyCode: json['currency_code'] as String,
        isActive: json['is_active'] as bool,
      );
}

class StaffService {
  const StaffService({required this.staffId, required this.serviceId});

  final String staffId;
  final String serviceId;

  Map<String, Object?> toJson() =>
      {'staff_id': staffId, 'service_id': serviceId};

  factory StaffService.fromJson(Map<String, Object?> json) => StaffService(
        staffId: json['staff_id'] as String,
        serviceId: json['service_id'] as String,
      );
}

/// فترة دوام محلية بتوقيت المركز؛ الدقائق منذ منتصف الليل.
class WorkingHours {
  const WorkingHours({
    required this.id,
    required this.staffId,
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
  });

  final String id;
  final String staffId;

  /// ISO: 1 الاثنين … 7 الأحد.
  final int weekday;
  final int startMinute;
  final int endMinute;

  Map<String, Object?> toJson() => {
        'id': id,
        'staff_id': staffId,
        'weekday': weekday,
        'start_minute': startMinute,
        'end_minute': endMinute,
      };

  factory WorkingHours.fromJson(Map<String, Object?> json) => WorkingHours(
        id: json['id'] as String,
        staffId: json['staff_id'] as String,
        weekday: json['weekday'] as int,
        startMinute: json['start_minute'] as int,
        endMinute: json['end_minute'] as int,
      );
}

class StaffTimeOff {
  const StaffTimeOff({
    required this.id,
    required this.staffId,
    required this.startsAt,
    required this.endsAt,
    this.reason,
  });

  final String id;
  final String staffId;
  final DateTime startsAt;
  final DateTime endsAt;

  /// داخلي للإدارة فقط.
  final String? reason;

  Map<String, Object?> toJson() => {
        'id': id,
        'staff_id': staffId,
        'starts_at': startsAt.toIso8601String(),
        'ends_at': endsAt.toIso8601String(),
        'reason': reason,
      };

  factory StaffTimeOff.fromJson(Map<String, Object?> json) => StaffTimeOff(
        id: json['id'] as String,
        staffId: json['staff_id'] as String,
        startsAt: _instant(json['starts_at']),
        endsAt: _instant(json['ends_at']),
        reason: json['reason'] as String?,
      );
}

class Booking {
  const Booking({
    required this.id,
    required this.customerId,
    required this.staffId,
    required this.serviceId,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.priceAtBooking,
    required this.currencyAtBooking,
    required this.createdAt,
    this.cancelledBy,
    this.cancelledAt,
    this.cancellationReason,
    this.completedAt,
  });

  static const duration = Duration(minutes: 30);

  final String id;
  final String customerId;
  final String staffId;
  final String serviceId;
  final DateTime startsAt;
  final DateTime endsAt;
  final BookingStatus status;
  final int priceAtBooking;
  final String currencyAtBooking;
  final DateTime createdAt;
  final String? cancelledBy;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime? completedAt;

  /// confirmed/completed يحجبان النطاق [start,end).
  bool get blocksSlot => status != BookingStatus.cancelled;

  Map<String, Object?> toJson() => {
        'id': id,
        'customer_id': customerId,
        'staff_id': staffId,
        'service_id': serviceId,
        'starts_at': startsAt.toIso8601String(),
        'ends_at': endsAt.toIso8601String(),
        'status': status.name,
        'price_at_booking': priceAtBooking,
        'currency_at_booking': currencyAtBooking,
        'created_at': createdAt.toIso8601String(),
        'cancelled_by': cancelledBy,
        'cancelled_at': cancelledAt?.toIso8601String(),
        'cancellation_reason': cancellationReason,
        'completed_at': completedAt?.toIso8601String(),
      };

  factory Booking.fromJson(Map<String, Object?> json) => Booking(
        id: json['id'] as String,
        customerId: json['customer_id'] as String,
        staffId: json['staff_id'] as String,
        serviceId: json['service_id'] as String,
        startsAt: _instant(json['starts_at']),
        endsAt: _instant(json['ends_at']),
        status: BookingStatus.values.byName(json['status'] as String),
        priceAtBooking: json['price_at_booking'] as int,
        currencyAtBooking: json['currency_at_booking'] as String,
        createdAt: _instant(json['created_at']),
        cancelledBy: json['cancelled_by'] as String?,
        cancelledAt: _optionalInstant(json['cancelled_at']),
        cancellationReason: json['cancellation_reason'] as String?,
        completedAt: _optionalInstant(json['completed_at']),
      );
}
