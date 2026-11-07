import 'package:flutter/material.dart';
import '../models/service.dart';
import '../theme/app_theme.dart';

class ServiceStyle {
  const ServiceStyle(this.icon, this.tint, this.accent);
  final IconData icon;
  final Color tint;
  final Color accent;

  static ServiceStyle forService(Service service) => switch (service.id) {
        'hair' => const ServiceStyle(
            Icons.content_cut_rounded, Color(0xFFFFEDE1), Color(0xFFCB7957)),
        'clean' => const ServiceStyle(
            Icons.ac_unit_rounded, Color(0xFFE1F3F8), Color(0xFF3C91A6)),
        'repair' => const ServiceStyle(
            Icons.laptop_mac_rounded, Color(0xFFEAE9FA), Color(0xFF786CB6)),
        'consult' => const ServiceStyle(
            Icons.menu_book_rounded, Color(0xFFFFF0D9), Color(0xFFBA8739)),
        _ => const ServiceStyle(
            Icons.auto_awesome_rounded, AppColors.mint, AppColors.teal),
      };
}

class ServiceIcon extends StatelessWidget {
  const ServiceIcon({super.key, required this.service, this.size = 58});
  final Service service;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = ServiceStyle.forService(service);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.tint,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(style.icon, color: style.accent, size: size * 0.46),
    );
  }
}

/// Bundled illustrative photos; never represents a verified provider.
class ServiceArtwork extends StatelessWidget {
  const ServiceArtwork({super.key, required this.service, this.height = 180});
  final Service service;
  final double height;
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset('assets/images/${service.id}.jpg',
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
                height: height,
                color: ServiceStyle.forService(service).tint,
                alignment: Alignment.center,
                child: ServiceIcon(service: service, size: 64))),
      );
}
