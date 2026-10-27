import '../models/models.dart';
import 'demo_state.dart';

/// بيانات التجربة الأولية: زبونان، أربعة موظفين، مدير (D-03).
abstract class DemoSeed {
  static const customerA = 'u-customer-a';
  static const customerB = 'u-customer-b';
  static const admin = 'u-admin';
  static const staffUsers = ['u-staff-a', 'u-staff-b', 'u-staff-c', 'u-staff-d'];
  static const staffIds = ['st-a', 'st-b', 'st-c', 'st-d'];

  static const haircut = 'sv-haircut';
  static const beard = 'sv-beard';
  static const facial = 'sv-facial';
  static const archived = 'sv-off';

  static DemoState build(DateTime now) {
    final names = {
      customerA: 'سارة الزبونة',
      customerB: 'خالد الزبون',
      staffUsers[0]: 'أحمد',
      staffUsers[1]: 'ليلى',
      staffUsers[2]: 'يوسف',
      staffUsers[3]: 'نور',
      admin: 'مدير المركز',
    };
    Profile profile(String id, UserRole role) =>
        Profile(id: id, fullName: names[id]!, role: role, createdAt: now);

    final profiles = [
      profile(customerA, UserRole.customer),
      profile(customerB, UserRole.customer),
      for (final id in staffUsers) profile(id, UserRole.staff),
      profile(admin, UserRole.admin),
    ];

    final staff = [
      for (var i = 0; i < staffIds.length; i++)
        StaffProfile(id: staffIds[i], userId: staffUsers[i], isActive: true),
    ];

    const services = [
      Service(id: haircut, name: 'قص شعر', priceMinor: 2500000, isActive: true),
      Service(id: beard, name: 'تهذيب لحية', priceMinor: 1500000, isActive: true),
      Service(id: facial, name: 'عناية بالبشرة', priceMinor: 4000000, isActive: true),
      Service(id: archived, name: 'خدمة متوقفة', priceMinor: 1000000, isActive: false),
    ];

    final links = <StaffService>[
      const StaffService(staffId: 'st-a', serviceId: haircut),
      const StaffService(staffId: 'st-a', serviceId: beard),
      const StaffService(staffId: 'st-b', serviceId: haircut),
      const StaffService(staffId: 'st-b', serviceId: facial),
      const StaffService(staffId: 'st-c', serviceId: beard),
      const StaffService(staffId: 'st-c', serviceId: facial),
      const StaffService(staffId: 'st-d', serviceId: haircut),
      const StaffService(staffId: 'st-d', serviceId: beard),
      const StaffService(staffId: 'st-d', serviceId: facial),
    ];

    var hoursSeq = 0;
    // الاثنين–السبت: 09:00–13:00 و16:00–20:00؛ الأحد عطلة.
    final hours = [
      for (final staffId in staffIds)
        for (var weekday = 1; weekday <= 6; weekday++) ...[
          WorkingHours(
            id: 'wh-${++hoursSeq}',
            staffId: staffId,
            weekday: weekday,
            startMinute: 9 * 60,
            endMinute: 13 * 60,
          ),
          WorkingHours(
            id: 'wh-${++hoursSeq}',
            staffId: staffId,
            weekday: weekday,
            startMinute: 16 * 60,
            endMinute: 20 * 60,
          ),
        ],
    ];

    return DemoState(
      accounts: [
        for (final p in profiles) DemoAccount(id: p.id, displayName: p.fullName),
      ],
      profiles: profiles,
      staff: staff,
      services: services,
      staffServices: links,
      workingHours: hours,
      timeOff: [],
      bookings: [],
      nextId: 1,
    );
  }
}
