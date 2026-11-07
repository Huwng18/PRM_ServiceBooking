import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/app_navigation.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import 'notifications_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _busy = false;
  Future<void> _editName() => showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _DisplayNameDialog(auth: context.read<AuthProvider>()),
      );

  Future<void> _logout() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await context.read<AuthProvider>().signOut();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Không thể đăng xuất. Vui lòng thử lại.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookings = context.watch<BookingProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final email = auth.email ?? '';
    final upcoming = bookings.byStatus(email, BookingStatus.upcoming).length;
    return SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
      Text('Tài khoản', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 6),
      const Text('Một góc nhỏ dành riêng cho bạn.'),
      const SizedBox(height: 24),
      SurfaceCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.mint,
              child: Text(auth.displayName.characters.first.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(auth.displayName,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(email)
              ]))
        ]),
        const SizedBox(height: 8),
        TextButton.icon(
            onPressed: _editName,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Sửa tên hiển thị')),
      ])),
      const SizedBox(height: 16),
      SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            _menu(
                Icons.calendar_month_outlined,
                'Lịch hẹn',
                '${bookings.byUser(email).length} lịch · $upcoming sắp tới',
                () => context.read<AppNavigation>().select(1)),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _menu(
                Icons.favorite_border_rounded,
                'Yêu thích',
                '${favorites.ids.length} dịch vụ',
                () => context.read<AppNavigation>().select(2)),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _menu(
                Icons.notifications_none_rounded,
                'Thông báo',
                '$upcoming nhắc lịch trong ứng dụng',
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen()))),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _menu(
                Icons.info_outline_rounded,
                'Về ứng dụng',
                'Hẹnio · Prototype PRM393',
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()))),
          ])),
      const SizedBox(height: 20),
      const SurfaceCard(
          color: AppColors.mint,
          child: Text(
              'Dữ liệu được lưu trên thiết bị này. Đăng xuất giữ lại lịch hẹn và yêu thích để bạn xem lại khi đăng nhập cùng email.')),
      const SizedBox(height: 24),
      OutlinedButton.icon(
          onPressed: _busy ? null : _logout,
          icon: const Icon(Icons.logout_rounded),
          label: Text(_busy ? 'Đang đăng xuất…' : 'Đăng xuất')),
      const SizedBox(height: 16),
      const Center(
          child: Text('hẹnio. · Thời gian của bạn luôn đáng giá.',
              style: TextStyle(fontSize: 12))),
    ]));
  }

  Widget _menu(
          IconData icon, String title, String subtitle, VoidCallback action) =>
      ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(icon, color: AppColors.teal),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded, size: 18),
          onTap: action);
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Về Hẹnio')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Brand(),
        const SizedBox(height: 24),
        Text('Đặt lịch theo cách của bạn.',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        const Text(
            'Service Booking là prototype Flutter cho môn PRM393. Bạn có thể khám phá dịch vụ, lưu yêu thích, đặt lịch, đổi lịch và quản lý lịch cá nhân.'),
        const SectionHeader('Dữ liệu & giới hạn'),
        const SurfaceCard(
            child: Text(
                '• Đăng nhập mô phỏng, không xác thực tài khoản thật.\n\n• Lịch hẹn lưu trong SQLite; phiên đăng nhập, tên và yêu thích lưu bằng SharedPreferences trên thiết bị.\n\n• Danh mục và giá là dữ liệu demo; ảnh chỉ minh họa.\n\n• Chưa kết nối lịch nhà cung cấp, chưa có thanh toán thật.\n\n• Chỉ nhắc lịch trong app, chưa có thông báo đẩy.\n\n• Dữ liệu không đồng bộ sang thiết bị khác.')),
      ]));
}

class _DisplayNameDialog extends StatefulWidget {
  const _DisplayNameDialog({required this.auth});
  final AuthProvider auth;
  @override
  State<_DisplayNameDialog> createState() => _DisplayNameDialogState();
}

class _DisplayNameDialogState extends State<_DisplayNameDialog> {
  late final TextEditingController _input;
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _input = TextEditingController(text: widget.auth.displayName);
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.auth.updateDisplayName(_input.text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e is ArgumentError
              ? e.message.toString()
              : 'Không thể lưu tên. Vui lòng thử lại.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_saving,
      child: AlertDialog(
        scrollable: true,
        title: const Text('Tên hiển thị'),
        content: TextField(
            controller: _input,
            autofocus: true,
            enabled: !_saving,
            maxLength: 40,
            decoration:
                InputDecoration(labelText: 'Tên của bạn', errorText: _error)),
        actions: [
          TextButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: const Text('Để sau')),
          TextButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Đang lưu…' : 'Lưu tên'))
        ],
      ));
}
