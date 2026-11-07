import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../providers/favorites_provider.dart';
import '../screens/service_detail_screen.dart';
import '../theme/app_theme.dart';
import 'app_components.dart';
import 'service_visual.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.service});
  final Service service;
  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final selected = favorites.contains(service.id);
    return IconButton.filledTonal(
      tooltip: selected ? 'Bỏ yêu thích' : 'Thêm yêu thích',
      style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: selected ? AppColors.coral : AppColors.ink),
      onPressed: favorites.busy
          ? null
          : () async {
              await favorites.toggle(service.id);
              if (context.mounted && favorites.error != null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(favorites.error!)));
              }
            },
      icon: Icon(
          selected ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 22),
    );
  }
}

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service});
  final Service service;
  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ServiceDetailScreen(service: service))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Stack(children: [
              ServiceArtwork(service: service, height: 156),
              Positioned(
                  top: 8, right: 8, child: FavoriteButton(service: service))
            ]),
            Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.category,
                          style: const TextStyle(
                              color: AppColors.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(service.name,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            Text('${service.durationMinutes} phút',
                                style: const TextStyle(color: AppColors.muted)),
                            Text(money(service.priceVnd),
                                style: const TextStyle(
                                    color: AppColors.teal,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800)),
                          ]),
                    ])),
          ]),
        ),
      );
}
