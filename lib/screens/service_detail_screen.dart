import 'package:flutter/material.dart';
import '../models/service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/service_card.dart';
import '../widgets/service_visual.dart';
import 'booking_form_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key, required this.service});
  final Service service;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết dịch vụ'), actions: [
          FavoriteButton(service: service),
          const SizedBox(width: 12)
        ]),
        body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              ServiceArtwork(service: service, height: 210),
              const SizedBox(height: 8),
              const Text('Ảnh minh họa', style: TextStyle(fontSize: 11)),
              const SizedBox(height: 16),
              Align(
                  alignment: Alignment.centerLeft,
                  child: StatusBadge(service.category)),
              const SizedBox(height: 12),
              Text(service.name,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(money(service.priceVnd),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: AppColors.teal)),
                    Text('${service.durationMinutes} phút · 08:00–18:00'),
                  ]),
              const SizedBox(height: 20),
              SurfaceCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const SectionHeader('Một chút về dịch vụ'),
                    Text(service.description),
                    const SectionHeader('Thông tin dịch vụ'),
                    _info(Icons.check_circle_outline_rounded,
                        service.description),
                    _info(Icons.schedule_rounded,
                        'Thời lượng dự kiến: ${service.durationMinutes} phút.'),
                    _info(Icons.edit_calendar_rounded,
                        'Bạn có thể đổi hoặc hủy lịch trước giờ hẹn.'),
                  ])),
              const SizedBox(height: 16),
              const SurfaceCard(
                  color: AppColors.mint,
                  child: Text(
                      'Đây là dịch vụ mẫu cho prototype PRM393. Lịch được lưu trên thiết bị, chưa kết nối lịch nhà cung cấp và chưa có thanh toán thật.')),
            ]),
        bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                          '${money(service.priceVnd)} · ${service.durationMinutes} phút',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      PrimaryButton(
                          label: 'Đặt lịch',
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      BookingFormScreen(service: service)))),
                    ]))),
      );
  Widget _info(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: AppColors.teal),
        const SizedBox(width: 10),
        Expanded(child: Text(text))
      ]));
}
