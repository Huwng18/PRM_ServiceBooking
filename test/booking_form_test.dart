import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:service_booking_flutter/data/booking_repository.dart';
import 'package:service_booking_flutter/data/demo_services.dart';
import 'package:service_booking_flutter/models/booking.dart';
import 'package:service_booking_flutter/providers/auth_provider.dart';
import 'package:service_booking_flutter/providers/booking_provider.dart';
import 'package:service_booking_flutter/screens/booking_form_screen.dart';
import 'package:service_booking_flutter/theme/app_theme.dart';

class PendingRepository extends BookingRepository {
  final pending = Completer<Booking>();
  int calls = 0;
  @override
  Future<List<Booking>> load() async => [];
  @override
  Future<Booking> create(
      {required String email,
      required String serviceId,
      required DateTime startAt,
      required String note}) {
    calls++;
    return pending.future;
  }
}

void main() {
  testWidgets('save is guarded and failure keeps date, time and note',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final auth = AuthProvider();
    await auth.signIn('demo@example.com', '123456');
    final repository = PendingRepository();
    final bookings = BookingProvider(repository);
    await bookings.initialize();
    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: bookings),
        ],
        child: MaterialApp(
            theme: buildAppTheme(),
            home: BookingFormScreen(service: demoServices.first))));
    await tester.tap(find.text('Ngày mai'));
    await tester.pump();
    await tester.ensureVisible(find.text('08:00'));
    await tester.tap(find.text('08:00'));
    await tester.pump();
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Giữ ghi chú này');
    await tester.tap(find.text('Xác nhận đặt lịch'));
    await tester.pump();
    expect(repository.calls, 1);
    expect(find.text('Đang lưu…'), findsOneWidget);
    await tester.tap(find.text('Đang lưu…'));
    expect(repository.calls, 1);
    repository.pending.completeError(StateError('disk full'));
    await tester.pumpAndSettle();
    expect(bookings.all, isEmpty);
    expect(find.text('Xác nhận đặt lịch'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Giữ ghi chú này');
    await tester.ensureVisible(find.textContaining('Không thể lưu lịch hẹn.'));
    expect(find.textContaining('Không thể lưu lịch hẹn.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    auth.dispose();
    bookings.dispose();
  });
}
