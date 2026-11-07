import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/demo_services.dart';
import '../models/booking.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/service_visual.dart';
import 'booking_form_screen.dart';

String statusLabel(BookingStatus status) => switch (status) {
      BookingStatus.upcoming => 'Sắp tới',
      BookingStatus.past => 'Đã qua',
      BookingStatus.cancelled => 'Đã hủy',
    };
void openBookingDetail(BuildContext context, String id, String email) =>
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => BookingDetailScreen(id: id, email: email)));

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.id, required this.email});
  final String id;
  final String email;
  Future<void> _cancel(BuildContext context) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
                title: const Text('Hủy lịch hẹn?'),
                content: const Text(
                    'Bạn có thể đặt lại dịch vụ vào thời gian khác.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Giữ lịch')),
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Hủy lịch',
                          style: TextStyle(color: AppColors.coral))),
                ]));
    if (confirm != true || !context.mounted) return;
    final error = await context.read<BookingProvider>().cancel(id, email);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error ?? 'Đã hủy lịch hẹn.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final activeEmail = context.watch<AuthProvider>().email;
    final booking = activeEmail == email
        ? provider.byUser(email).where((b) => b.id == id).firstOrNull
        : null;
    final service =
        demoServices.where((s) => s.id == booking?.serviceId).firstOrNull;
    final status = booking?.statusAt(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết lịch hẹn')),
      body: booking == null
          ? const AppEmptyState(
              icon: Icons.event_busy,
              title: 'Không tìm thấy lịch hẹn',
              message: 'Lịch hẹn không có trong tài khoản hiện tại.')
          : ListView(padding: const EdgeInsets.all(20), children: [
              if (service != null) ...[
                ServiceArtwork(service: service, height: 160),
                const SizedBox(height: 20)
              ],
              Text(service?.name ?? booking.serviceId,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Align(
                  alignment: Alignment.centerLeft,
                  child: StatusBadge(statusLabel(status!),
                      cancelled: booking.cancelled)),
              const SizedBox(height: 20),
              SurfaceCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const SectionHeader('Thời gian của bạn'),
                    Text(
                        '${dateLabel(booking.startAt)} · ${timeLabel(booking.startAt)}',
                        style: Theme.of(context).textTheme.titleMedium),
                    if (service != null) ...[
                      const SizedBox(height: 8),
                      Text(
                          '${service.durationMinutes} phút · ${money(service.priceVnd)}')
                    ],
                    const SectionHeader('Ghi chú'),
                    Text(booking.note.isEmpty
                        ? 'Không có ghi chú.'
                        : booking.note),
                  ])),
              const SizedBox(height: 16),
              const Text(
                  'Lịch demo lưu trên thiết bị. Trạng thái “Sắp tới” không phải xác nhận từ nhà cung cấp.'),
              const SizedBox(height: 24),
              if (status == BookingStatus.upcoming) ...[
                if (service != null)
                  PrimaryButton(
                      label: 'Đổi lịch hẹn',
                      icon: Icons.edit_calendar_outlined,
                      onPressed: provider.saving
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => BookingFormScreen(
                                      service: service,
                                      existingBooking: booking)))),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                    onPressed: provider.saving ? null : () => _cancel(context),
                    icon: const Icon(Icons.close_rounded),
                    label: Text(provider.saving ? 'Đang lưu…' : 'Hủy lịch hẹn'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.coral)),
              ] else if (service != null)
                PrimaryButton(
                    label: 'Đặt lại dịch vụ',
                    icon: Icons.replay_rounded,
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                BookingFormScreen(service: service)))),
            ]),
    );
  }
}
