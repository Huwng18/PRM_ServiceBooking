import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import '../models/booking.dart';

/// SQLite repository. Data survives application restarts on mobile devices.
class BookingRepository {
  Database? _database;
  Future<Database> _open() async {
    if (_database != null) return _database!;
    final dbPath = path.join(await getDatabasesPath(), 'service_booking.db');
    _database = await openDatabase(dbPath, version: 1, onCreate: (db, version) async {
      await db.execute("""
        CREATE TABLE bookings (
          id TEXT PRIMARY KEY,
          user_email TEXT NOT NULL,
          service_id TEXT NOT NULL,
          start_at TEXT NOT NULL,
          note TEXT NOT NULL,
          cancelled INTEGER NOT NULL DEFAULT 0
        )
      """);
      await db.execute('CREATE INDEX idx_booking_user ON bookings(user_email)');
    });
    return _database!;
  }

  Future<List<Booking>> load() async {
    final db = await _open();
    final rows = await db.query('bookings', orderBy: 'start_at DESC');
    return rows.map((r) => Booking(
      id: r['id'] as String,
      userEmail: r['user_email'] as String,
      serviceId: r['service_id'] as String,
      startAt: DateTime.parse(r['start_at'] as String),
      note: r['note'] as String,
      cancelled: (r['cancelled'] as int) == 1,
    )).toList();
  }

  Future<void> save(List<Booking> records) async {
    final db = await _open();
    await db.transaction((txn) async {
      // Small prototype: replace snapshot atomically.
      await txn.delete('bookings');
      for (final b in records) {
        await txn.insert('bookings', {
          'id': b.id,
          'user_email': b.userEmail,
          'service_id': b.serviceId,
          'start_at': b.startAt.toIso8601String(),
          'note': b.note,
          'cancelled': b.cancelled ? 1 : 0,
        });
      }
    });
  }
}
