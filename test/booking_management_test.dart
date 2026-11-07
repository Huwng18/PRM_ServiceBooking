import 'package:flutter_test/flutter_test.dart';
import 'package:service_booking_flutter/data/booking_repository.dart';
import 'package:service_booking_flutter/models/booking.dart';
import 'package:service_booking_flutter/providers/booking_provider.dart';

class SnapshotRepository extends BookingRepository {
  SnapshotRepository(this.records);
  final List<Booking> records;
  bool fail = false;
  @override
  Future<List<Booking>> load() async => List.of(records);
  @override
  Future<Booking> reschedule(
      {required String id,
      required String email,
      required DateTime startAt,
      required String note}) async {
    if (fail) throw StateError('disk full');
    final old = records.singleWhere((b) => b.id == id);
    return Booking(
        id: old.id,
        userEmail: old.userEmail,
        serviceId: old.serviceId,
        startAt: startAt,
        note: note);
  }

  @override
  Future<Booking> cancel(String id, String email) async {
    if (fail) throw StateError('disk full');
    return records.singleWhere((b) => b.id == id).cancel();
  }
}

void main() {
  final now = DateTime(2027, 1, 1, 9);
  Booking row(String id, DateTime time,
          {String email = 'a@b.com', bool cancelled = false}) =>
      Booking(
          id: id,
          userEmail: email,
          serviceId: 'hair',
          startAt: time,
          note: '',
          cancelled: cancelled);
  test(
      'classification counts only own future non-cancelled bookings and orders them',
      () async {
    final provider = BookingProvider(SnapshotRepository([
      row('late', now.add(const Duration(days: 3))),
      row('soon', now.add(const Duration(days: 1))),
      row('past-old', now.subtract(const Duration(days: 3))),
      row('past-new', now.subtract(const Duration(days: 1))),
      row('now', now),
      row('cancelled', now.add(const Duration(days: 1)), cancelled: true),
      row('other', now.add(const Duration(days: 1)), email: 'other@b.com'),
    ]));
    await provider.initialize();
    expect(
        provider
            .byStatus('a@b.com', BookingStatus.upcoming, now: now)
            .map((b) => b.id),
        ['soon', 'late']);
    expect(
        provider
            .byStatus('a@b.com', BookingStatus.past, now: now)
            .map((b) => b.id),
        ['now', 'past-new', 'past-old']);
    expect(
        provider
            .byStatus('a@b.com', BookingStatus.cancelled, now: now)
            .single
            .id,
        'cancelled');
    provider.dispose();
  });
  test(
      'rescheduling updates the existing id once; failed changes leave data intact',
      () async {
    final original = row('same-id', now.add(const Duration(days: 1)));
    final repository = SnapshotRepository([original]);
    final provider = BookingProvider(repository);
    await provider.initialize();
    final changed = now.add(const Duration(days: 2));
    expect(
        await provider.reschedule(
            id: original.id,
            userEmail: original.userEmail,
            startAt: changed,
            note: 'Đổi giờ'),
        isNull);
    expect(provider.all.single.id, original.id);
    expect(provider.all.single.startAt, changed);
    repository.fail = true;
    expect(await provider.cancel(original.id, original.userEmail), isNotNull);
    expect(provider.all.single.startAt, changed);
    expect(provider.all.single.cancelled, isFalse);
    provider.dispose();
  });
  test('change policy rejects past, cancelled and other owner', () {
    expect(BookingRules.canChange(row('now', now), 'a@b.com', now: now),
        isNotNull);
    expect(
        BookingRules.canChange(
            row('future', now.add(const Duration(days: 1))), 'other@b.com',
            now: now),
        isNotNull);
    expect(
        BookingRules.canChange(
            row('cancel', now.add(const Duration(days: 1)), cancelled: true),
            'a@b.com',
            now: now),
        isNotNull);
    expect(
        BookingRules.canChange(
            row('ok', now.add(const Duration(days: 1))), 'a@b.com',
            now: now),
        isNull);
  });
}
