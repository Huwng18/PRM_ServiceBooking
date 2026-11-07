import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this.auth) {
    auth.addListener(_onAuth);
  }
  final AuthProvider auth;
  SharedPreferences? _prefs;
  Set<String> _ids = {};
  String? _email;
  bool busy = false;
  String? error;
  Set<String> get ids => Set.unmodifiable(_ids);
  bool contains(String id) => _ids.contains(id);
  String _key(String email) => 'service_booking_favorites_v1_$email';
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _onAuth();
    } catch (_) {
      error = 'Không thể tải yêu thích. Vui lòng thử lại.';
      notifyListeners();
    }
  }

  void _onAuth() {
    if (_email == auth.email && _prefs != null) return;
    _email = auth.email;
    _ids = _email == null
        ? {}
        : (_prefs?.getStringList(_key(_email!)) ?? []).toSet();
    notifyListeners();
  }

  Future<void> toggle(String id) async {
    if (busy || _email == null) return;
    final email = _email!;
    busy = true;
    error = null;
    notifyListeners();
    final next = {..._ids};
    if (!next.add(id)) next.remove(id);
    try {
      _prefs ??= await SharedPreferences.getInstance();
      if (!await _prefs!.setStringList(_key(email), next.toList())) {
        throw StateError('save');
      }
      if (_email == email) _ids = next;
    } catch (_) {
      error = 'Không thể lưu yêu thích. Vui lòng thử lại.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    auth.removeListener(_onAuth);
    super.dispose();
  }
}
