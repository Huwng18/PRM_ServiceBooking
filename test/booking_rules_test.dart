import 'package:flutter_test/flutter_test.dart';
import 'package:service_booking_flutter/models/booking.dart';
import 'package:service_booking_flutter/providers/booking_provider.dart';

void main() {
  final now = DateTime(2027, 1, 1, 9);
  test('rejects appointments in the past', () {
    final error = BookingRules.validate(startAt: DateTime(2026, 12, 31, 10),
      durationMinutes: 45, existing: [], userEmail: 'a@b.com',
      serviceId: 'hair', now: now);
    expect(error, isNotNull);
  });
  test('rejects overlapping appointments for the same service', () {
    final existing = [Booking(id: '1', userEmail: 'a@b.com',
      serviceId: 'hair', startAt: DateTime(2027, 1, 3, 10), note: '')];
    final error = BookingRules.validate(startAt: DateTime(2027, 1, 3, 10, 30),
      durationMinutes: 45, existing: existing, userEmail: 'a@b.com',
      serviceId: 'hair', now: now);
    expect(error, contains('đã có lịch'));
  });
  test('accepts valid booking', () {
    final error = BookingRules.validate(startAt: DateTime(2027, 1, 3, 14),
      durationMinutes: 45, existing: [], userEmail: 'a@b.com',
      serviceId: 'hair', now: now);
    expect(error, isNull);
  });
}
