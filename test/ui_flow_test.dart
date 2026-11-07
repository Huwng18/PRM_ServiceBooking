import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:service_booking_flutter/data/booking_repository.dart';
import 'package:service_booking_flutter/data/demo_services.dart';
import 'package:service_booking_flutter/models/booking.dart';
import 'package:service_booking_flutter/providers/app_navigation.dart';
import 'package:service_booking_flutter/providers/auth_provider.dart';
import 'package:service_booking_flutter/providers/booking_provider.dart';
import 'package:service_booking_flutter/providers/favorites_provider.dart';
import 'package:service_booking_flutter/screens/home_screen.dart';
import 'package:service_booking_flutter/screens/booking_form_screen.dart';
import 'package:service_booking_flutter/screens/login_screen.dart';
import 'package:service_booking_flutter/screens/notifications_screen.dart';
import 'package:service_booking_flutter/screens/booking_detail_screen.dart';
import 'package:service_booking_flutter/screens/service_detail_screen.dart';
import 'package:service_booking_flutter/theme/app_theme.dart';

class UiRepository extends BookingRepository {
  @override
  Future<List<Booking>> load() async => List.generate(
      24,
      (i) => Booking(
          id: '$i',
          userEmail: 'demo@example.com',
          serviceId: 'hair',
          startAt: DateTime.now().add(Duration(days: i + 1)),
          note: 'Ghi chú kiểm tra hiển thị đầy đủ.'));
}

class UiFixture {
  final auth = AuthProvider();
  final bookings = BookingProvider(UiRepository());
  final navigation = AppNavigation();
  late FavoritesProvider favorites;
  Future<void> initialize() async {
    SharedPreferences.setMockInitialValues({});
    await auth.signIn('demo@example.com', '123456');
    await bookings.initialize();
    favorites = FavoritesProvider(auth);
    await favorites.initialize();
  }

  Widget app(Widget home, {double scale = 1}) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider.value(value: bookings),
            ChangeNotifierProvider.value(value: favorites),
            ChangeNotifierProvider.value(value: navigation),
          ],
          child: MaterialApp(
              theme: buildAppTheme(),
              builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!),
              home: home));
  void dispose() {
    favorites.dispose();
    auth.dispose();
    bookings.dispose();
    navigation.dispose();
  }
}

void main() {
  testWidgets('search survives detail navigation and favorites synchronize',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fixture = UiFixture();
    await fixture.initialize();
    await tester.pumpWidget(fixture.app(const HomeScreen()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextField).first);
    await tester.enterText(find.byType(TextField).first, 'cat toc');
    await tester.pumpAndSettle();
    expect(find.text('1 dịch vụ'), findsOneWidget);
    await tester.ensureVisible(find.text('Cắt tóc & tạo kiểu').first);
    await tester.tap(find.text('Cắt tóc & tạo kiểu').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Thêm yêu thích'));
    await tester.pumpAndSettle();
    expect(fixture.favorites.ids, {'hair'});
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'cat toc');
    expect(find.byTooltip('Bỏ yêu thích'), findsOneWidget);
    fixture.navigation.select(2);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Bỏ yêu thích'));
    await tester.pumpAndSettle();
    expect(find.text('Lưu lại điều bạn thích'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    fixture.dispose();
  });

  for (final config in [
    (const Size(320, 640), 1.0),
    (const Size(320, 640), 2.0),
    (const Size(430, 932), 1.0)
  ]) {
    testWidgets('screens fit ${config.$1} with text scale ${config.$2}',
        (tester) async {
      tester.view.physicalSize = config.$1;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fixture = UiFixture();
      await fixture.initialize();
      await fixture.favorites.toggle('hair');
      for (var index = 0; index < 4; index++) {
        fixture.navigation.select(index);
        await tester
            .pumpWidget(fixture.app(const HomeScreen(), scale: config.$2));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Home tab $index');
        if (index == 0) {
          await tester.ensureVisible(find.text('Khám phá ngay'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Khám phá ngay'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull,
              reason: 'banner scroll destination');
        }
        if (index == 3) {
          await tester.scrollUntilVisible(find.text('Sửa tên hiển thị'), 120,
              scrollable: find.byType(Scrollable).first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Sửa tên hiển thị'));
          await tester.pumpAndSettle();
          tester.view.viewInsets = const FakeViewPadding(bottom: 300);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull,
              reason: 'name dialog with keyboard');
          await tester.enterText(find.byType(TextField), 'Nguyễn An');
          await tester.tap(find.text('Lưu tên'));
          await tester.pumpAndSettle();
          expect(fixture.auth.displayName, 'Nguyễn An');
          tester.view.resetViewInsets();
          await tester.pumpAndSettle();
        }
      }
      for (final screen in <Widget>[
        const LoginScreen(),
        const NotificationsScreen(),
        BookingDetailScreen(id: '0', email: fixture.auth.email!),
        ServiceDetailScreen(service: demoServices.first),
        BookingFormScreen(service: demoServices.first),
        BookingSuccessScreen(
            service: demoServices.first,
            startAt: DateTime.now().add(const Duration(days: 1))),
      ]) {
        await tester.pumpWidget(fixture.app(screen, scale: config.$2));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '${screen.runtimeType}');
        if (screen is BookingFormScreen) {
          tester.view.viewInsets = const FakeViewPadding(bottom: 300);
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(find.byType(TextField), 160,
              scrollable: find.byType(Scrollable).first);
          await tester.enterText(
              find.byType(TextField), 'Ghi chú khi mở bàn phím');
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull,
              reason: 'booking keyboard open');
          tester.view.resetViewInsets();
          await tester.pumpAndSettle();
        }
      }
      await tester
          .pumpWidget(fixture.app(const LoginScreen(), scale: config.$2));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
          find.byKey(const Key('passwordField')), 120,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'keyboard open');
      tester.view.resetViewInsets();
      await tester.pumpWidget(const SizedBox());
      fixture.dispose();
    });
  }
}
