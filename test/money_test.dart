import 'package:flutter_test/flutter_test.dart';
import 'package:service_booking_flutter/screens/services_screen.dart';

void main() {
  test('formats Vietnamese dong without a leading separator', () {
    expect(money(0), '0 đ');
    expect(money(120000), '120.000 đ');
    expect(money(1250000), '1.250.000 đ');
  });
}
