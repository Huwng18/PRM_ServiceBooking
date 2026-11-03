import 'package:flutter/material.dart';

import '../models/service.dart';
import '../theme/app_theme.dart';
import '../widgets/service_visual.dart';
import 'booking_form_screen.dart';
import 'services_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key, required this.service});

  final Service service;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết dịch vụ')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          ServiceArtwork(service: service, height: 220),
          const SizedBox(height: 25),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(service.category,
                    style: const TextStyle(
                        color: AppColors.teal,
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 9),
              const Icon(Icons.verified_rounded,
                  size: 17, color: AppColors.teal),
              const SizedBox(width: 4),
              const Expanded(
                  child: Text('Đặt lịch linh hoạt',
                      style: TextStyle(fontSize: 12, color: AppColors.muted))),
            ],
          ),
          const SizedBox(height: 13),
          Text(service.name, style: textTheme.headlineMedium),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                  child: _DetailMetric(
                icon: Icons.schedule_rounded,
                label: 'Thời lượng',
                value: '${service.durationMinutes} phút',
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _DetailMetric(
                icon: Icons.payments_outlined,
                label: 'Giá dịch vụ',
                value: money(service.priceVnd),
              )),
            ],
          ),
          const SizedBox(height: 29),
          Text('Về dịch vụ', style: textTheme.titleLarge),
          const SizedBox(height: 9),
          Text(service.description,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.muted,
              )),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.event_available_rounded, color: AppColors.teal),
                SizedBox(width: 12),
                Expanded(
                    child: Text(
                  'Chọn ngày và khung giờ phù hợp. Lịch hẹn của bạn sẽ được lưu ngay trên thiết bị.',
                  style: TextStyle(color: AppColors.ink, height: 1.5),
                )),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 13, 20, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Từ',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      )),
                  Text(money(service.priceVnd), style: textTheme.titleMedium),
                ],
              )),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BookingFormScreen(service: service))),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 19),
                  label: const Text('Đặt lịch ngay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.teal, size: 22),
            const SizedBox(height: 12),
            Text(label,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                )),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                )),
          ],
        ),
      );
}
