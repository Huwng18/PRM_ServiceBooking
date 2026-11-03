import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'services_screen.dart';
import 'my_bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().email ?? '';
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          const ServicesScreen(),
          MyBookingsScreen(email: email),
          _AccountScreen(email: email),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: NavigationBar(
          height: 72,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.mint,
          selectedIndex: _tab,
          onDestinationSelected: (value) => setState(() => _tab = value),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon:
                  Icon(Icons.grid_view_rounded, color: AppColors.teal),
              label: 'Khám phá',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon:
                  Icon(Icons.calendar_month_rounded, color: AppColors.teal),
              label: 'Lịch hẹn',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.teal),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountScreen extends StatelessWidget {
  const _AccountScreen({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
          children: [
            const Text('TÀI KHOẢN CỦA BẠN',
                style: TextStyle(
                  color: AppColors.teal,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                )),
            const SizedBox(height: 7),
            Text('Xin chào!', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: AppColors.teal, size: 32),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tài khoản demo',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(email,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted)),
                    ],
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.teal),
                  SizedBox(width: 14),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dữ liệu trên thiết bị',
                          style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: 5),
                      Text(
                          'Lịch hẹn được lưu cục bộ để bạn xem lại sau khi mở ứng dụng.',
                          style:
                              TextStyle(color: AppColors.muted, height: 1.4)),
                    ],
                  )),
                ],
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: () => context.read<AuthProvider>().signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Đăng xuất'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.line),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17)),
              ),
            ),
          ],
        ),
      );
}
