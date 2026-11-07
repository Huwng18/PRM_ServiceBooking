import 'package:flutter/foundation.dart';
import '../data/booking_repository.dart';
import '../domain/booking_rules.dart';
import '../models/booking.dart';
import '../models/service.dart';
export '../domain/booking_rules.dart' show BookingRules;

class BookingProvider extends ChangeNotifier {
  BookingProvider(this._repository);
  final BookingRepository _repository;
  List<Booking> _bookings = [];
  List<Booking> get all => List.unmodifiable(_bookings);
  bool loading = false;
  bool saving = false;
  String? error;

  Future<void> initialize() async {
    if (loading || saving) return;
    loading = true;
    notifyListeners();
    try {
      _bookings = await _repository.load();
      error = null;
    } catch (_) {
      error = 'Không thể tải lịch hẹn. Vui lòng thử lại.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  List<Booking> byUser(String email) =>
      _bookings.where((b) => b.userEmail == email).toList()
        ..sort((a, b) => b.startAt.compareTo(a.startAt));
  List<Booking> byStatus(String email, BookingStatus status, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final records =
        byUser(email).where((b) => b.statusAt(current) == status).toList();
    records.sort((a, b) => status == BookingStatus.upcoming
        ? a.startAt.compareTo(b.startAt)
        : b.startAt.compareTo(a.startAt));
    return records;
  }

  Future<String?> _mutate(Future<Booking> Function() action) async {
    if (saving || loading) return 'Đang xử lý lịch hẹn. Vui lòng đợi.';
    if (error != null) return 'Vui lòng tải lại lịch hẹn trước khi thay đổi.';
    saving = true;
    notifyListeners();
    try {
      final booking = await action();
      final index = _bookings.indexWhere((b) => b.id == booking.id);
      if (index < 0) {
        _bookings.add(booking);
      } else {
        _bookings[index] = booking;
      }
      return null;
    } on BookingIssue catch (e) {
      return e.message;
    } catch (_) {
      return 'Không thể lưu lịch hẹn. Thông tin đã nhập được giữ lại, vui lòng thử lại.';
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<String?> book(
          {required String userEmail,
          required Service service,
          required DateTime startAt,
          required String note}) =>
      _mutate(() => _repository.create(
          email: userEmail,
          serviceId: service.id,
          startAt: startAt,
          note: note));
  Future<String?> reschedule(
          {required String id,
          required String userEmail,
          required DateTime startAt,
          required String note}) =>
      _mutate(() => _repository.reschedule(
          id: id, email: userEmail, startAt: startAt, note: note));
  Future<String?> cancel(String id, String userEmail) =>
      _mutate(() => _repository.cancel(id, userEmail));
}
