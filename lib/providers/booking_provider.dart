import 'package:flutter/foundation.dart';
import '../data/booking_repository.dart';
import '../data/demo_services.dart';
import '../models/booking.dart';
import '../models/service.dart';

class BookingRules {
  static String? validate({required DateTime startAt, required int durationMinutes,
    required List<Booking> existing, required String userEmail, required String serviceId,
    DateTime? now}) {
    final current = now ?? DateTime.now();
    if (!startAt.isAfter(current)) return 'Vui lòng chọn thời gian trong tương lai.';
    if (startAt.hour < 8 || startAt.hour >= 18 ||
        startAt.add(Duration(minutes: durationMinutes)).day != startAt.day ||
        startAt.add(Duration(minutes: durationMinutes)).hour > 18 ||
        (startAt.add(Duration(minutes: durationMinutes)).hour == 18 &&
         startAt.add(Duration(minutes: durationMinutes)).minute > 0)) {
      return 'Giờ phục vụ: 08:00–18:00.';
    }
    final end = startAt.add(Duration(minutes: durationMinutes));
    for (final booking in existing) {
      if (booking.cancelled || booking.userEmail != userEmail ||
          booking.serviceId != serviceId) {
        continue;
      }
      // A simple same-service 60-min time-slot conflict rule.
      final otherDuration = demoServices.where((s) => s.id == booking.serviceId).firstOrNull?.durationMinutes ?? 60;
      final otherEnd = booking.startAt.add(Duration(minutes: otherDuration));
      if (startAt.isBefore(otherEnd) && end.isAfter(booking.startAt)) {
        return 'Bạn đã có lịch cho dịch vụ này vào khung giờ đó.';
      }
    }
    return null;
  }
}

class BookingProvider extends ChangeNotifier {
  BookingProvider(this._repository);
  final BookingRepository _repository;
  List<Booking> _bookings = [];
  List<Booking> get all => List.unmodifiable(_bookings);
  bool loading = false;
  String? error;

  Future<void> initialize() async {
    loading = true;
    notifyListeners();
    try { _bookings = await _repository.load(); error = null; }
    catch (e) { error = 'Không thể tải lịch hẹn: $e'; }
    finally { loading = false; notifyListeners(); }
  }
  List<Booking> byUser(String email) => _bookings.where((b) => b.userEmail == email).toList()
    ..sort((a, b) => b.startAt.compareTo(a.startAt));

  Future<String?> book({required String userEmail, required Service service,
    required DateTime startAt, required String note}) async {
    final issue = BookingRules.validate(startAt: startAt,
      durationMinutes: service.durationMinutes, existing: _bookings,
      userEmail: userEmail, serviceId: service.id);
    if (issue != null) return issue;
    final old = List<Booking>.from(_bookings);
    _bookings.add(Booking(id: DateTime.now().microsecondsSinceEpoch.toString(),
      userEmail: userEmail, serviceId: service.id, startAt: startAt, note: note));
    notifyListeners();
    try { await _repository.save(_bookings); return null; }
    catch (_) { _bookings = old; notifyListeners(); return 'Lưu thất bại. Vui lòng thử lại.'; }
  }

  Future<String?> cancel(String id, String userEmail) async {
    final index = _bookings.indexWhere((b) => b.id == id && b.userEmail == userEmail && !b.cancelled);
    if (index < 0) return 'Không tìm thấy lịch hẹn hợp lệ.';
    if (!_bookings[index].startAt.isAfter(DateTime.now())) return 'Không thể hủy lịch đã qua.';
    final old = List<Booking>.from(_bookings);
    _bookings[index] = _bookings[index].cancel();
    notifyListeners();
    try { await _repository.save(_bookings); return null; }
    catch (_) { _bookings = old; notifyListeners(); return 'Không thể lưu thay đổi.'; }
  }
}
