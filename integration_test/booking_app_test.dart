import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:service_booking_flutter/main.dart' as app;
import 'package:service_booking_flutter/data/booking_repository.dart';
import 'package:service_booking_flutter/domain/booking_rules.dart'
    show BookingIssue;
import 'package:service_booking_flutter/providers/auth_provider.dart';
import 'package:service_booking_flutter/providers/booking_provider.dart';
import 'package:service_booking_flutter/providers/favorites_provider.dart';
import 'package:service_booking_flutter/providers/app_navigation.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('SQLite v1 data, transaction validation and reopen persistence',
      (tester) async {
    final dbPath = path.join(await getDatabasesPath(),
        'henio_qa_sqlite_${DateTime.now().microsecondsSinceEpoch}.db');
    final db = await openDatabase(dbPath, version: 1, onCreate: (db, _) async {
      await db.execute(
          'CREATE TABLE bookings (id TEXT PRIMARY KEY, user_email TEXT NOT NULL, service_id TEXT NOT NULL, start_at TEXT NOT NULL, note TEXT NOT NULL, cancelled INTEGER NOT NULL DEFAULT 0)');
      await db.execute('CREATE INDEX idx_booking_user ON bookings(user_email)');
      await db.insert('bookings', {
        'id': 'legacy',
        'user_email': 'a@b.com',
        'service_id': 'hair',
        'start_at': DateTime(2027, 1, 3, 10).toIso8601String(),
        'note': 'Dữ liệu v1 cũ',
        'cancelled': 0
      });
      await db.insert('bookings', {
        'id': 'past',
        'user_email': 'a@b.com',
        'service_id': 'hair',
        'start_at': DateTime(2026, 1, 3, 10).toIso8601String(),
        'note': '',
        'cancelled': 0
      });
    });
    expect(await db.getVersion(), 1);
    await db.close();
    final repository = BookingRepository(
        databasePath: dbPath, now: () => DateTime(2027, 1, 1));
    addTearDown(() async {
      await repository.close();
      await deleteDatabase(dbPath);
    });
    expect((await repository.load()).singleWhere((b) => b.id == 'legacy').note,
        'Dữ liệu v1 cũ');
    await expectLater(
        repository.create(
            email: 'a@b.com',
            serviceId: 'hair',
            startAt: DateTime(2027, 1, 3, 10, 30),
            note: ''),
        throwsA(isA<BookingIssue>()));
    await expectLater(
        repository.create(
            email: 'a@b.com',
            serviceId: 'clean',
            startAt: DateTime(2027, 1, 3, 17),
            note: ''),
        throwsA(isA<BookingIssue>()));
    await expectLater(
        repository.cancel('past', 'a@b.com'), throwsA(isA<BookingIssue>()));
    await expectLater(repository.cancel('legacy', 'other@b.com'),
        throwsA(isA<BookingIssue>()));
    final results = await Future.wait(List.generate(2, (_) async {
      try {
        return await repository.create(
            email: 'a@b.com',
            serviceId: 'hair',
            startAt: DateTime(2027, 1, 3, 13),
            note: '');
      } catch (e) {
        return e;
      }
    }));
    expect(results.whereType<BookingIssue>().length, 1);
    await expectLater(
        repository.reschedule(
            id: 'legacy',
            email: 'a@b.com',
            startAt: DateTime(2027, 1, 3, 13),
            note: ''),
        throwsA(isA<BookingIssue>()));
    final changed = await repository.reschedule(
        id: 'legacy',
        email: 'a@b.com',
        startAt: DateTime(2027, 1, 3, 10, 30),
        note: 'Đã đổi');
    expect(changed.id, 'legacy');
    expect((await repository.load()).where((b) => b.id == 'legacy').length, 1);
    await repository.cancel('legacy', 'a@b.com');
    await repository.create(
        email: 'a@b.com',
        serviceId: 'hair',
        startAt: DateTime(2027, 1, 3, 10, 30),
        note: 'Đặt lại');
    await repository.create(
        email: 'other@b.com',
        serviceId: 'hair',
        startAt: DateTime(2027, 1, 3, 10, 30),
        note: 'Người khác');
    await repository.close();
    final restored = await repository.load();
    expect(restored.length, 5);
    expect(restored.singleWhere((b) => b.id == 'legacy').cancelled, isTrue);
    expect(restored.singleWhere((b) => b.id == 'legacy').note, 'Đã đổi');
    final provider = BookingProvider(repository);
    await provider.initialize();
    expect(provider.byUser('other@b.com').length, 1);
    expect(provider.byUser('a@b.com').length, 4);
    provider.dispose();
  });

  testWidgets(
      'Android discovery to favorites booking reschedule cancel and restore',
      (tester) async {
    final prefs = await SharedPreferences.getInstance();
    const sessionKey = 'service_booking_session_v1';
    final previousSession = prefs.getString(sessionKey);
    final email = 'qa${DateTime.now().microsecondsSinceEpoch}@henio.invalid';
    final dbPath = path.join(await getDatabasesPath(),
        'henio_qa_ui_${DateTime.now().microsecondsSinceEpoch}.db');
    final repository = BookingRepository(databasePath: dbPath);
    final auth = AuthProvider();
    final bookings = BookingProvider(repository);
    final favorites = FavoritesProvider(auth);
    final navigation = AppNavigation();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      favorites.dispose();
      bookings.dispose();
      auth.dispose();
      navigation.dispose();
      await repository.close();
      await deleteDatabase(dbPath);
      if (previousSession == null) {
        await prefs.remove(sessionKey);
      } else {
        await prefs.setString(sessionKey, previousSession);
      }
      await prefs.remove('service_booking_favorites_v1_$email');
      await prefs.remove('service_booking_name_v1_$email');
    });
    await prefs.remove(sessionKey);
    await auth.initialize();
    await bookings.initialize();
    await favorites.initialize();
    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider.value(value: bookings),
      ChangeNotifierProvider.value(value: favorites),
      ChangeNotifierProvider.value(value: navigation),
    ], child: const app.BookingApp()));
    await tester.pumpAndSettle();
    final imageContext = tester.element(find.byType(app.BookingApp));
    for (final image in ['forest', 'hair', 'clean', 'repair', 'consult']) {
      await precacheImage(AssetImage('assets/images/$image.jpg'), imageContext);
    }
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('henio-login');
    await tester.enterText(find.byKey(const Key('emailField')), email);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('loginButton')));
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();
    await auth.updateDisplayName('Nguyễn An');
    await tester.pumpAndSettle();
    await binding.takeScreenshot('henio-discovery');
    await tester.ensureVisible(find.byType(TextField).first);
    await tester.enterText(find.byType(TextField).first, 'cat toc');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Bộ lọc'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dưới 150.000 đ'));
    await tester.tap(find.text('Áp dụng'));
    await tester.pumpAndSettle();
    expect(find.text('1 dịch vụ'), findsOneWidget);
    await tester.ensureVisible(find.text('Cắt tóc & tạo kiểu').first);
    await tester.tap(find.byTooltip('Thêm yêu thích'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cắt tóc & tạo kiểu').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Bỏ yêu thích'), findsOneWidget);
    await binding.takeScreenshot('henio-service-detail');
    await tester.tap(find.text('Đặt lịch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ngày mai'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('10:00'));
    await tester.tap(find.text('10:00'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Ghi chú demo');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('01 · Ngày hẹn'), -160,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await binding.takeScreenshot('henio-booking-form');
    await tester.tap(find.text('Xác nhận đặt lịch'));
    await tester.pumpAndSettle();
    expect(find.text('Đặt lịch thành công!'), findsOneWidget);
    final id = bookings.byUser(email).single.id;
    await binding.takeScreenshot('henio-booking-success');
    await tester.tap(find.text('Xem lịch hẹn'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('henio-bookings');
    await tester.tap(find.text('Xem chi tiết & quản lý'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Đổi lịch hẹn'));
    await tester.tap(find.text('Đổi lịch hẹn'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('11:00'));
    await tester.tap(find.text('11:00'));
    await tester.pumpAndSettle();
    // Abandoning the form must not mutate the existing record.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(bookings.byUser(email).single.startAt.hour, 10);
    await tester.tap(find.text('Đổi lịch hẹn'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('11:00'));
    await tester.tap(find.text('11:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận đổi lịch'));
    await tester.pumpAndSettle();
    expect(find.text('Đã đổi lịch hẹn!'), findsOneWidget);
    expect(bookings.byUser(email).single.id, id);
    expect(bookings.byUser(email).single.startAt.hour, 11);
    await tester.tap(find.text('Xem lịch hẹn'));
    await tester.pumpAndSettle();
    navigation.select(3);
    await tester.pumpAndSettle();
    await binding.takeScreenshot('henio-account');
    await tester.ensureVisible(find.text('Thông báo'));
    await tester.tap(find.text('Thông báo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('11:00'), findsOneWidget);
    await binding.takeScreenshot('henio-reminders');
    await tester.tap(find.text('Cắt tóc & tạo kiểu'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Hủy lịch hẹn'));
    await tester.tap(find.text('Hủy lịch hẹn'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Hủy lịch'));
    await tester.pumpAndSettle();
    expect(bookings.byUser(email).single.cancelled, isTrue);
    await binding.takeScreenshot('henio-cancelled');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Bạn đã xem hết rồi'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    navigation.select(1);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đã hủy (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xem chi tiết & quản lý'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Đặt lại dịch vụ'));
    await tester.tap(find.text('Đặt lại dịch vụ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ngày mai'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('12:00'));
    await tester.tap(find.text('12:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận đặt lịch'));
    await tester.pumpAndSettle();
    expect(bookings.byUser(email).length, 2);
    expect(
        bookings.byUser(email).singleWhere((b) => !b.cancelled).id, isNot(id));
    await tester.tap(find.text('Xem lịch hẹn'));
    await tester.pumpAndSettle();
    navigation.select(2);
    await tester.pumpAndSettle();
    await binding.takeScreenshot('henio-favorites');
    await repository.close();
    final restored = BookingProvider(repository);
    await restored.initialize();
    expect(restored.byUser(email).length, 2);
    expect(restored.byUser(email).singleWhere((b) => b.id == id).cancelled,
        isTrue);
    restored.dispose();
    final restoredAuth = AuthProvider();
    await restoredAuth.initialize();
    expect(restoredAuth.email, email);
    expect(restoredAuth.displayName, 'Nguyễn An');
    final restoredFavorites = FavoritesProvider(restoredAuth);
    await restoredFavorites.initialize();
    expect(restoredFavorites.ids, {'hair'});
    await auth.signOut();
    expect(favorites.ids, isEmpty);
    expect(bookings.byUser(auth.email ?? ''), isEmpty);
    await auth.signIn('another_$email', '123456');
    expect(bookings.byUser(auth.email!), isEmpty);
    expect(favorites.ids, isEmpty);
    await prefs.remove('service_booking_favorites_v1_another_$email');
    restoredFavorites.dispose();
    restoredAuth.dispose();
    expect(tester.takeException(), isNull);
  });
}
