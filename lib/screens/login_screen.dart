import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_navigation.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'demo@example.com');
  final _password = TextEditingController(text: '123456');
  bool _busy = false;
  bool _showPassword = false;
  String? _error;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // Reset navigation only when it is provided (standalone widget tests omit it).
      context.read<AppNavigation?>()?.select(0);
      await context.read<AuthProvider>().signIn(_email.text, _password.text);
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Không thể đăng nhập demo. Kiểm tra thông tin và thử lại.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: SafeArea(
              child: Center(
                  child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24),
            children: [
              const Brand(),
              const SizedBox(height: 24),
              ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/images/forest.jpg',
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink())),
              const SizedBox(height: 24),
              Text('Chào bạn,\nđặt lịch thôi!',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text('Bớt bận rộn. Thêm thảnh thơi.'),
              const SizedBox(height: 24),
              Form(
                  key: _form,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                            key: const Key('emailField'),
                            controller: _email,
                            enabled: !_busy,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon:
                                    Icon(Icons.alternate_email_rounded)),
                            validator: (v) => v == null ||
                                    !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                        .hasMatch(v.trim())
                                ? 'Nhập email hợp lệ'
                                : null),
                        const SizedBox(height: 16),
                        TextFormField(
                            key: const Key('passwordField'),
                            controller: _password,
                            enabled: !_busy,
                            obscureText: !_showPassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                                labelText: 'Mật khẩu',
                                prefixIcon:
                                    const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                    tooltip: _showPassword
                                        ? 'Ẩn mật khẩu'
                                        : 'Hiện mật khẩu',
                                    onPressed: () => setState(
                                        () => _showPassword = !_showPassword),
                                    icon: Icon(_showPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined))),
                            validator: (v) => v == null || v.length < 6
                                ? 'Ít nhất 6 ký tự'
                                : null),
                        const SizedBox(height: 20),
                        PrimaryButton(
                            key: const Key('loginButton'),
                            label: 'Đăng nhập',
                            busy: _busy,
                            onPressed: _submit),
                        if (_error != null)
                          Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(_error!,
                                  style:
                                      const TextStyle(color: AppColors.coral))),
                      ])),
              const SizedBox(height: 20),
              const SurfaceCard(
                  color: AppColors.mint,
                  child: Text(
                      'Đăng nhập mô phỏng: email hợp lệ và mật khẩu từ 6 ký tự. Không dùng thông tin thật. Dữ liệu lưu trên thiết bị, mật khẩu không được lưu.',
                      style: TextStyle(fontSize: 13))),
              const SizedBox(height: 20),
              const Text('SERVICE BOOKING · PRM393',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, letterSpacing: 1.5)),
            ]),
      ))));
}
