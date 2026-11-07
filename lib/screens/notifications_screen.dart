import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/demo_services.dart';
import '../models/booking.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../widgets/app_components.dart';
import 'booking_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final Timer _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().email ?? '';
    final provider = context.watch<BookingProvider>();
    final records = provider.byStatus(email, BookingStatus.upcoming);
    return Scaffold(
        appBar: AppBar(title: const Text('Nhắc lịch của bạn')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          const SurfaceCard(
              child: Text(
                  'Nhắc lịch hiển thị khi bạn mở ứng dụng. Chưa có thông báo đẩy hoặc nhắc lịch ngoài ứng dụng.')),
          const SizedBox(height: 16),
          if (provider.loading)
            const Center(child: CircularProgressIndicator())
          else if (provider.error != null)
            AppEmptyState(
                icon: Icons.error_outline,
                title: 'Chưa thể tải nhắc lịch',
                message: provider.error!,
                action: OutlinedButton(
                    onPressed: provider.initialize,
                    child: const Text('Thử lại')))
          else if (records.isEmpty)
            const AppEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'Bạn đã xem hết rồi',
                message: 'Lịch hẹn sắp tới sẽ được nhắc tại đây.')
          else
            for (final booking in records)
              Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                      child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.event_available_outlined),
                    title: Text(demoServices
                            .where((s) => s.id == booking.serviceId)
                            .firstOrNull
                            ?.name ??
                        booking.serviceId),
                    subtitle: Text(
                        'Bạn có lịch lúc ${timeLabel(booking.startAt)} · ${dateLabel(booking.startAt)}'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => openBookingDetail(context, booking.id, email),
                  ))),
        ]));
  }
}
