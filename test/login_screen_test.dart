import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:service_booking_flutter/providers/auth_provider.dart';
import 'package:service_booking_flutter/screens/login_screen.dart';

void main() {
  testWidgets('invalid email displays validation message', (tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MaterialApp(home: LoginScreen()),
    ));
    await tester.enterText(find.byKey(const Key('emailField')), 'wrong-email');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();
    expect(find.text('Nhập email hợp lệ'), findsOneWidget);
  });
}
