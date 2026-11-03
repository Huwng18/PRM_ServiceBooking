import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'data/booking_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthProvider();
  final bookings = BookingProvider(BookingRepository());
  await Future.wait([auth.initialize(), bookings.initialize()]);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: auth),
    ChangeNotifierProvider.value(value: bookings),
  ], child: const BookingApp()));
}

class BookingApp extends StatelessWidget {
  const BookingApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Service Booking',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('vi'),
        supportedLocales: const [Locale('vi'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Consumer<AuthProvider>(
            builder: (_, auth, __) =>
                auth.signedIn ? const HomeScreen() : const LoginScreen()),
      );
}
