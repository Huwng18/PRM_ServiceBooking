import 'package:flutter_test/flutter_test.dart';
import 'package:service_booking_flutter/models/booking.dart';
import 'package:service_booking_flutter/providers/booking_provider.dart';

void main() {
  final now = DateTime(2027, 1, 1, 9);
  Booking booking(
          {String id = '1',
          String email = 'a@b.com',
          String service = 'hair',
          bool cancelled = false}) =>
      Booking(
          id: id,
          userEmail: email,
          serviceId: service,
          startAt: DateTime(2027, 1, 3, 10),
          note: '',
          cancelled: cancelled);
  String? validate(DateTime time,
          {int duration = 45,
          List<Booking> existing = const [],
          String? exclude}) =>
      BookingRules.validate(
          startAt: time,
          durationMinutes: duration,
          existing: existing,
          userEmail: 'a@b.com',
          serviceId: 'hair',
          now: now,
          excludeBookingId: exclude);
  test('rejects past and exact current time', () {
    expect(validate(now.subtract(const Duration(minutes: 1))), isNotNull);
    expect(validate(now), isNotNull);
  });
  test('service may finish exactly at 18:00 but not a minute later', () {
    expect(validate(DateTime(2027, 1, 3, 17, 15)), isNull);
    expect(validate(DateTime(2027, 1, 3, 17, 16)), isNotNull);
    expect(validate(DateTime(2027, 1, 3, 16, 30), duration: 90), isNull);
    expect(validate(DateTime(2027, 1, 3, 17), duration: 90), isNotNull);
  });
  test('opening time, midnight and invalid duration boundaries', () {
    expect(validate(DateTime(2027, 1, 3, 8)), isNull);
    expect(validate(DateTime(2027, 1, 3, 7, 59)), isNotNull);
    expect(validate(DateTime(2027, 1, 3, 18)), isNotNull);
    expect(validate(DateTime(2027, 1, 3, 23, 30), duration: 90), isNotNull);
    expect(validate(DateTime(2027, 1, 3, 10), duration: 0), isNotNull);
  });
  test('rejects every overlap shape, accepts touching intervals', () {
    for (final minute in [16, 30, 59]) {
      expect(validate(DateTime(2027, 1, 3, 9, minute), existing: [booking()]),
          isNotNull);
    }
    for (final minute in [0, 15, 44]) {
      expect(validate(DateTime(2027, 1, 3, 10, minute), existing: [booking()]),
          isNotNull);
    }
    expect(
        validate(DateTime(2027, 1, 3, 9, 15), existing: [booking()]), isNull);
    expect(
        validate(DateTime(2027, 1, 3, 10, 45), existing: [booking()]), isNull);
  });
  test('cancelled, other email and other service do not conflict', () {
    for (final other in [
      booking(cancelled: true),
      booking(email: 'other@b.com'),
      booking(service: 'clean')
    ]) {
      expect(validate(DateTime(2027, 1, 3, 10), existing: [other]), isNull);
    }
  });
  test('rescheduling ignores itself but checks other appointments', () {
    expect(
        validate(DateTime(2027, 1, 3, 10), existing: [booking()], exclude: '1'),
        isNull);
    expect(
        validate(DateTime(2027, 1, 3, 10),
            existing: [booking(), booking(id: '2')], exclude: '1'),
        isNotNull);
  });
  test('accepts valid booking',
      () => expect(validate(DateTime(2027, 1, 3, 14)), isNull));
  test('local and UTC timestamps represent the same interval', () {
    final start = DateTime(2027, 1, 3, 10);
    expect(validate(start.toUtc(), existing: [booking()]), isNotNull);
  });
}
