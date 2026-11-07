import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:service_booking_flutter/providers/auth_provider.dart';
import 'package:service_booking_flutter/providers/favorites_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('favorites survive restart and are isolated by email', () async {
    final auth = AuthProvider();
    await auth.initialize();
    final favorites = FavoritesProvider(auth);
    await favorites.initialize();
    await auth.signIn('A@b.com', '123456');
    await favorites.toggle('hair');
    expect(favorites.contains('hair'), isTrue);
    await auth.signOut();
    expect(favorites.ids, isEmpty);
    await auth.signIn('other@b.com', '123456');
    expect(favorites.ids, isEmpty);
    await auth.signIn('a@b.com', '123456');
    final restored = FavoritesProvider(auth);
    await restored.initialize();
    expect(restored.ids, {'hair'});
    await restored.toggle('hair');
    expect(restored.ids, isEmpty);
    favorites.dispose();
    restored.dispose();
    auth.dispose();
  });
}
