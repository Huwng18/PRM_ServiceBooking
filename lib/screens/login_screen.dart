import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate() || _busy) return;
    setState(() => _busy = true);
    try {
      await context.read<AuthProvider>().signIn(_email.text, _password.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final compact = constraints.maxHeight < 720;
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(children: [
                _hero(compact),
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: _formCard(compact),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(28, 0, 28, 32),
                  child: Text(
                    'Một tài khoản, mọi lịch hẹn trong tầm tay.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                ),
              ]),
            );
          }),
        ),
      );

  Widget _hero(bool compact) => Container(
        height: compact ? 160 : 285,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.ink, Color(0xFF0A6862)],
          ),
        ),
        child: Stack(children: [
          Positioned(
            right: -44,
            top: -80,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 48,
            bottom: -65,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    25, compact ? 12 : 28, 25, compact ? 24 : 42),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.calendar_month_rounded,
                            color: Colors.white, size: 23),
                      ),
                      const SizedBox(width: 11),
                      const Text('SERVICE BOOKING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.w800,
                          )),
                    ]),
                    SizedBox(height: compact ? 15 : 38),
                    Text('Chào bạn,\nđặt lịch thôi!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 27 : 37,
                          height: 1.12,
                          letterSpacing: -0.8,
                          fontWeight: FontWeight.w800,
                        )),
                    if (!compact) ...[
                      const SizedBox(height: 13),
                      Text('Dịch vụ phù hợp, thời gian theo ý bạn.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 15,
                          )),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ]),
      );

  Widget _formCard(bool compact) => Container(
        padding: EdgeInsets.all(compact ? 20 : 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 12),
            )
          ],
        ),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Đăng nhập',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              const Text('Rất vui được gặp lại bạn.',
                  style: TextStyle(color: AppColors.muted, fontSize: 14)),
              SizedBox(height: compact ? 18 : 25),
              TextFormField(
                key: const Key('emailField'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: (v) => v == null ||
                        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(v.trim())
                    ? 'Nhập email hợp lệ'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('passwordField'),
                controller: _password,
                obscureText: !_showPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _showPassword ? 'Ẩn mật khẩu' : 'Hiện mật khẩu',
                    icon: Icon(_showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Ít nhất 6 ký tự' : null,
              ),
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('loginButton'),
                onPressed: _busy ? null : _submit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_busy ? 'Đang xử lý...' : 'Đăng nhập'),
                    if (!_busy) ...[
                      const SizedBox(width: 9),
                      const Icon(Icons.arrow_forward_rounded, size: 19),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 17),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18, color: AppColors.teal),
                  SizedBox(width: 9),
                  Expanded(
                      child: Text(
                    'Tài khoản demo: nhập email hợp lệ và mật khẩu từ 6 ký tự.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.ink, height: 1.35),
                  )),
                ]),
              ),
            ],
          ),
        ),
      );
}
