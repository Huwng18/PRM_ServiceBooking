import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import '../models/booking.dart';
import '../data/demo_services.dart';
import '../domain/booking_rules.dart';

/// SQLite v1 is retained so existing installations need no schema migration.
class BookingRepository {
  BookingRepository({this.databasePath, DateTime Function()? now})
      : _now = now ?? DateTime.now;
  final String? databasePath;
  final DateTime Function() _now;
  Future<Database>? _database;
  Future<Database> _open() => _database ??= _openDatabase();
  Future<Database> _openDatabase() async {
    try {
      return await openDatabase(
          databasePath ??
              path.join(await getDatabasesPath(), 'service_booking.db'),
          version: 1, onCreate: (db, version) async {
        await db.execute('''CREATE TABLE bookings (
          id TEXT PRIMARY KEY, user_email TEXT NOT NULL, service_id TEXT NOT NULL,
          start_at TEXT NOT NULL, note TEXT NOT NULL, cancelled INTEGER NOT NULL DEFAULT 0
        )''');
        await db
            .execute('CREATE INDEX idx_booking_user ON bookings(user_email)');
      });
    } catch (_) {
      _database = null;
      rethrow;
    }
  }

  Booking _fromRow(Map<String, Object?> r) => Booking(
      id: r['id'] as String,
      userEmail: r['user_email'] as String,
      serviceId: r['service_id'] as String,
      startAt: DateTime.parse(r['start_at'] as String).toLocal(),
      note: r['note'] as String,
      cancelled: (r['cancelled'] as int) == 1);
  Map<String, Object?> _toRow(Booking b) => {
        'id': b.id,
        'user_email': b.userEmail,
        'service_id': b.serviceId,
        'start_at': b.startAt.toLocal().toIso8601String(),
        'note': b.note,
        'cancelled': b.cancelled ? 1 : 0,
      };
  Future<List<Booking>> _read(DatabaseExecutor db) async =>
      (await db.query('bookings', orderBy: 'start_at DESC'))
          .map(_fromRow)
          .toList();
  Future<List<Booking>> load() async => _read(await _open());

  Future<Booking> create(
      {required String email,
      required String serviceId,
      required DateTime startAt,
      required String note}) async {
    final db = await _open();
    return db.transaction((txn) async {
      final records = await _read(txn);
      final normalized = email.trim().toLowerCase();
      _validate(records, normalized, serviceId, startAt, note);
      var id = DateTime.now().microsecondsSinceEpoch.toString();
      while (records.any((b) => b.id == id)) {
        id = '${id}1';
      }
      final booking = Booking(
          id: id,
          userEmail: normalized,
          serviceId: serviceId,
          startAt: startAt.toLocal(),
          note: note.trim());
      await txn.insert('bookings', _toRow(booking));
      return booking;
    });
  }

  Future<Booking> reschedule(
      {required String id,
      required String email,
      required DateTime startAt,
      required String note}) async {
    final db = await _open();
    return db.transaction((txn) async {
      final records = await _read(txn);
      final old = records.where((b) => b.id == id).firstOrNull;
      final issue = BookingRules.canChange(old, email, now: _now());
      if (issue != null) throw BookingIssue(issue);
      _validate(records, email, old!.serviceId, startAt, note, excludeId: id);
      final updated = Booking(
          id: old.id,
          userEmail: old.userEmail,
          serviceId: old.serviceId,
          startAt: startAt.toLocal(),
          note: note.trim());
      await txn.update('bookings', _toRow(updated),
          where: 'id = ? AND user_email = ?', whereArgs: [id, email]);
      return updated;
    });
  }

  Future<Booking> cancel(String id, String email) async {
    final db = await _open();
    return db.transaction((txn) async {
      final rows =
          await txn.query('bookings', where: 'id = ?', whereArgs: [id]);
      final old = rows.isEmpty ? null : _fromRow(rows.single);
      final issue = BookingRules.canChange(old, email, now: _now());
      if (issue != null) throw BookingIssue(issue);
      final updated = old!.cancel();
      await txn.update('bookings', {'cancelled': 1},
          where: 'id = ? AND user_email = ?', whereArgs: [id, email]);
      return updated;
    });
  }

  void _validate(List<Booking> records, String email, String serviceId,
      DateTime startAt, String note,
      {String? excludeId}) {
    final service = demoServices.where((s) => s.id == serviceId).firstOrNull;
    if (email.isEmpty || service == null) {
      throw const BookingIssue(
          'Thông tin người dùng hoặc dịch vụ không hợp lệ.');
    }
    if (note.trim().length > 500) {
      throw const BookingIssue('Ghi chú tối đa 500 ký tự.');
    }
    final issue = BookingRules.validate(
        startAt: startAt,
        durationMinutes: service.durationMinutes,
        existing: records,
        userEmail: email,
        serviceId: serviceId,
        now: _now(),
        excludeBookingId: excludeId);
    if (issue != null) throw BookingIssue(issue);
  }

  Future<void> close() async {
    final db = _database;
    _database = null;
    if (db != null) await (await db).close();
  }
}
