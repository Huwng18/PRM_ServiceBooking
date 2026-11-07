import '../data/demo_services.dart';
import '../models/booking.dart';

class BookingIssue implements Exception {
  const BookingIssue(this.message);
  final String message;
  @override
  String toString() => message;
}

class BookingRules {
  static String? validate(
      {required DateTime startAt,
      required int durationMinutes,
      required List<Booking> existing,
      required String userEmail,
      required String serviceId,
      DateTime? now,
      String? excludeBookingId}) {
    final start = startAt.toLocal();
    final current = (now ?? DateTime.now()).toLocal();
    if (!start.isAfter(current)) {
      return 'Vui lòng chọn thời gian trong tương lai.';
    }
    final open = DateTime(start.year, start.month, start.day, 8);
    final close = DateTime(start.year, start.month, start.day, 18);
    final end = start.add(Duration(minutes: durationMinutes));
    if (durationMinutes <= 0 || start.isBefore(open) || end.isAfter(close)) {
      return 'Giờ phục vụ: 08:00–18:00. Dịch vụ phải kết thúc trước hoặc đúng 18:00.';
    }
    for (final booking in existing) {
      if (booking.id == excludeBookingId ||
          booking.cancelled ||
          booking.userEmail != userEmail ||
          booking.serviceId != serviceId) {
        continue;
      }
      final duration = demoServices
              .where((s) => s.id == booking.serviceId)
              .firstOrNull
              ?.durationMinutes ??
          60;
      final otherStart = booking.startAt.toLocal();
      final otherEnd = otherStart.add(Duration(minutes: duration));
      if (start.isBefore(otherEnd) && end.isAfter(otherStart)) {
        return 'Bạn đã có lịch cho dịch vụ này vào khung giờ đó.';
      }
    }
    return null;
  }

  static String? canChange(Booking? booking, String email, {DateTime? now}) {
    if (booking == null || booking.userEmail != email || booking.cancelled) {
      return 'Không tìm thấy lịch hẹn hợp lệ.';
    }
    if (!booking.startAt.isAfter(now ?? DateTime.now())) {
      return 'Không thể thay đổi lịch đã qua.';
    }
    return null;
  }
}
