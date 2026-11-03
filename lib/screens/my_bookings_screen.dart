import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/demo_services.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/service_visual.dart';
import 'services_screen.dart';

class MyBookingsScreen extends StatelessWidget {
  final String email;
  const MyBookingsScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final records = provider.byUser(email);
    final upcoming = records
        .where((b) => !b.cancelled && b.startAt.isAfter(DateTime.now()))
        .length;

    return SafeArea(
      child: Column(children: [
        _header(context, upcoming),
        if (provider.loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (provider.error != null)
          Expanded(
              child: Center(
                  child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(provider.error!, textAlign: TextAlign.center),
          )))
        else if (records.isEmpty)
          const Expanded(child: _EmptyBookings())
        else
          Expanded(
              child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) =>
                _bookingCard(context, records[index]),
          )),
      ]),
    );
  }

  Widget _header(BuildContext context, int upcoming) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('QUẢN LÝ LỊCH HẸN',
              style: TextStyle(
                color: AppColors.teal,
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 7),
          Text('Lịch hẹn của bạn',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 7),
          const Text('Theo dõi những dịch vụ đã đặt tại đây.',
              style: TextStyle(color: AppColors.muted, fontSize: 14)),
          const SizedBox(height: 19),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.event_available_rounded,
                    color: Colors.white),
              ),
              const SizedBox(width: 15),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lịch sắp tới',
                      style: TextStyle(color: Color(0xFFD2E6E1), fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                      upcoming == 0
                          ? 'Chưa có lịch nào'
                          : '$upcoming lịch đang chờ bạn',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17)),
                ],
              )),
            ]),
          ),
        ]),
      );

  Widget _bookingCard(BuildContext context, Booking booking) {
    final service =
        demoServices.where((s) => s.id == booking.serviceId).firstOrNull;
    final canCancel =
        !booking.cancelled && booking.startAt.isAfter(DateTime.now());
    final status = booking.cancelled
        ? 'Đã hủy'
        : canCancel
            ? 'Sắp tới'
            : 'Đã qua';
    final statusColor = booking.cancelled
        ? AppColors.coral
        : canCancel
            ? AppColors.teal
            : AppColors.muted;
    final statusBackground = booking.cancelled
        ? AppColors.peach
        : canCancel
            ? AppColors.mint
            : AppColors.canvas;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (service != null)
            ServiceIcon(service: service, size: 52)
          else
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(15),
              ),
              child:
                  const Icon(Icons.event_note_rounded, color: AppColors.teal),
            ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(service?.name ?? booking.serviceId,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium),
              if (service != null) ...[
                const SizedBox(height: 3),
                Text(service.category,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 13)),
              ],
            ],
          )),
        ]),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.teal),
            const SizedBox(width: 8),
            Expanded(
                child: Text(_date(booking.startAt),
                    style: const TextStyle(
                        color: AppColors.ink, fontWeight: FontWeight.w600))),
            const Icon(Icons.schedule_rounded, size: 18, color: AppColors.teal),
            const SizedBox(width: 6),
            Text(_time(booking.startAt),
                style: const TextStyle(
                    color: AppColors.ink, fontWeight: FontWeight.w700)),
          ]),
        ),
        if (booking.note.isNotEmpty) ...[
          const SizedBox(height: 13),
          Text('Ghi chú: ${booking.note}',
              style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        ],
        const SizedBox(height: 14),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: statusBackground,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(status,
                style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          if (service != null)
            Text(money(service.priceVnd),
                style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 15)),
        ]),
        if (canCancel) ...[
          const SizedBox(height: 13),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 9),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: AppColors.coral),
              onPressed: () => _confirmCancel(context, booking),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Hủy lịch'),
            ),
          ),
        ],
      ]),
    );
  }

  Future<void> _confirmCancel(BuildContext context, Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hủy lịch hẹn?'),
        content: const Text('Bạn có chắc muốn hủy lịch hẹn này?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Giữ lịch')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.coral),
            child: const Text('Hủy lịch'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final result =
        await context.read<BookingProvider>().cancel(booking.id, email);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result ?? 'Đã hủy lịch.')),
      );
    }
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _time(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mint,
                ),
                child: const Icon(Icons.event_note_rounded,
                    color: AppColors.teal, size: 43),
              ),
              const SizedBox(height: 22),
              Text('Chưa có lịch hẹn',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Chọn một dịch vụ bạn thích và tạo lịch hẹn đầu tiên.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, height: 1.5)),
            ],
          ),
        ),
      );
}
