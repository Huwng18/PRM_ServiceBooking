import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_navigation.dart';
import '../theme/app_theme.dart';
import 'services_screen.dart';
import 'my_bookings_screen.dart';
import 'favorites_screen.dart';
import 'account_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().email ?? '';
    final navigation = context.watch<AppNavigation>();
    return Scaffold(
        body: IndexedStack(index: navigation.index, children: [
          const ServicesScreen(),
          MyBookingsScreen(email: email),
          const FavoritesScreen(),
          const AccountScreen(),
        ]),
        bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line))),
            child: NavigationBar(
              height: 76,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              indicatorColor: AppColors.mint,
              selectedIndex: navigation.index,
              onDestinationSelected: navigation.select,
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.grid_view_outlined),
                    selectedIcon:
                        Icon(Icons.grid_view_rounded, color: AppColors.teal),
                    label: 'Khám phá'),
                NavigationDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    selectedIcon: Icon(Icons.calendar_month_rounded,
                        color: AppColors.teal),
                    label: 'Lịch hẹn'),
                NavigationDestination(
                    icon: Icon(Icons.favorite_border_rounded),
                    selectedIcon:
                        Icon(Icons.favorite_rounded, color: AppColors.teal),
                    label: 'Yêu thích'),
                NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon:
                        Icon(Icons.person_rounded, color: AppColors.teal),
                    label: 'Tài khoản'),
              ],
            )));
  }
}
