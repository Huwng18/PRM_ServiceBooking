import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/demo_services.dart';
import '../providers/favorites_provider.dart';
import '../providers/app_navigation.dart';
import '../widgets/app_components.dart';
import '../widgets/service_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final items = demoServices.where((s) => favorites.contains(s.id)).toList();
    return SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
      Text('Yêu thích', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 6),
      Text('${items.length} dịch vụ bạn muốn dành thời gian cho mình.'),
      const SizedBox(height: 20),
      if (favorites.error != null)
        AppEmptyState(
            icon: Icons.error_outline,
            title: 'Chưa thể tải yêu thích',
            message: favorites.error!,
            action: OutlinedButton(
                onPressed: favorites.initialize, child: const Text('Thử lại'))),
      if (items.isEmpty)
        AppEmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'Lưu lại điều bạn thích',
            message: 'Chạm trái tim trên dịch vụ để dễ dàng tìm lại ở đây.',
            action: PrimaryButton(
                label: 'Khám phá dịch vụ',
                onPressed: () => context.read<AppNavigation>().select(0))),
      for (final service in items)
        Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ServiceCard(service: service)),
    ]));
  }
}
