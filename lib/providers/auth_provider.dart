import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const _key = 'service_booking_session_v1';
  String? _email;
  String? get email => _email;
  bool get signedIn => _email != null;
  bool ready = false;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _email = prefs.getString(_key);
    ready = true;
    notifyListeners();
  }
  Future<void> signIn(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalized)) {
      throw ArgumentError('Email không hợp lệ.');
    }
    if (password.length < 6) throw ArgumentError('Mật khẩu phải có ít nhất 6 ký tự.');
    // Mock authentication only. NOT secure server authentication.
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(_key, normalized)) throw StateError('Không thể lưu phiên.');
    _email = normalized;
    notifyListeners();
  }
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    _email = null;
    notifyListeners();
  }
}
