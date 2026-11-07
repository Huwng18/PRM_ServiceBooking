import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const _key = 'service_booking_session_v1';
  String? _email;
  String? get email => _email;
  bool get signedIn => _email != null;
  bool ready = false;
  String _displayName = '';
  String get displayName => _displayName.isNotEmpty
      ? _displayName
      : (_email?.split('@').first ?? 'Bạn');
  String _nameKey(String email) => 'service_booking_name_v1_$email';
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _email = prefs.getString(_key);
    _displayName =
        _email == null ? '' : prefs.getString(_nameKey(_email!)) ?? '';
    ready = true;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalized)) {
      throw ArgumentError('Email không hợp lệ.');
    }
    if (password.length < 6) {
      throw ArgumentError('Mật khẩu phải có ít nhất 6 ký tự.');
    }
    // Mock auth only: passwords are never persisted or logged.
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(_key, normalized)) {
      throw StateError('Không thể lưu phiên đăng nhập.');
    }
    _email = normalized;
    _displayName = prefs.getString(_nameKey(normalized)) ?? '';
    notifyListeners();
  }

  Future<void> updateDisplayName(String value) async {
    final name = value.trim();
    if (name.isEmpty || name.length > 40) {
      throw ArgumentError('Tên cần có từ 1 đến 40 ký tự.');
    }
    final email = _email;
    if (email == null) {
      throw StateError('Vui lòng đăng nhập lại.');
    }
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(_nameKey(email), name)) {
      throw StateError('Không thể lưu tên. Vui lòng thử lại.');
    }
    if (_email == email) {
      _displayName = name;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.remove(_key)) {
      throw StateError('Không thể đăng xuất. Vui lòng thử lại.');
    }
    _email = null;
    _displayName = '';
    notifyListeners();
  }
}
