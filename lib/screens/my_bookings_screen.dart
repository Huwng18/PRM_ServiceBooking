import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/demo_services.dart';
import '../models/booking.dart';
import '../providers/app_navigation.dart';
import '../providers/booking_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/service_visual.dart';
import 'booking_detail_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key, required this.email});
  final String email;
  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  BookingStatus _status = BookingStatus.upcoming;
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
    final provider = context.watch<BookingProvider>();
    final now = DateTime.now();
    final records = provider.byStatus(widget.email, _status, now: now);
    final upcoming = provider
        .byStatus(widget.email, BookingStatus.upcoming, now: now)
        .length;
    return SafeArea(
        child: RefreshIndicator(
            onRefresh: provider.initialize,
            child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  Text('Lịch hẹn của bạn',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  const Text('Dành thời gian cho những điều bạn cần.'),
                  const SizedBox(height: 20),
                  SurfaceCard(
                      color: AppColors.mint,
                      child: Row(children: [
                        const Icon(Icons.event_available_outlined,
                            color: AppColors.teal),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(
                                upcoming == 0
                                    ? 'Bạn chưa có lịch sắp tới.'
                                    : '$upcoming lịch sắp tới đang chờ bạn.',
                                style: const TextStyle(
                                    color: AppColors.teal,
                                    fontWeight: FontWeight.w700)))
                      ])),
                  const SizedBox(height: 16),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final entry in [
                      (BookingStatus.upcoming, 'Sắp tới'),
                      (BookingStatus.past, 'Đã qua'),
                      (BookingStatus.cancelled, 'Đã hủy')
                    ])
                      ChoiceChip(
                          label: Text(
                              '${entry.$2} (${provider.byStatus(widget.email, entry.$1, now: now).length})'),
                          selected: _status == entry.$1,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _status = entry.$1))
                  ]),
                  const SizedBox(height: 16),
                  if (provider.loading)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator()))
                  else if (provider.error != null)
                    AppEmptyState(
                        icon: Icons.error_outline,
                        title: 'Chưa thể tải lịch hẹn',
                        message: provider.error!,
                        action: OutlinedButton(
                            onPressed: provider.initialize,
                            child: const Text('Thử lại')))
                  else if (records.isEmpty)
                    AppEmptyState(
                        icon: Icons.calendar_today_outlined,
                        title: 'Chưa có lịch ở mục này',
                        message:
                            'Khám phá dịch vụ và chọn thời gian phù hợp với bạn.',
                        action: PrimaryButton(
                            label: 'Khám phá dịch vụ',
                            onPressed: () =>
                                context.read<AppNavigation>().select(0)))
                  else
                    for (final booking in records)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _card(context, booking)),
                ])));
  }

  Widget _card(BuildContext context, Booking booking) {
    final service =
        demoServices.where((s) => s.id == booking.serviceId).firstOrNull;
    return Card(
        child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => openBookingDetail(context, booking.id, widget.email),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        if (service != null) ...[
                          ServiceIcon(service: service, size: 48),
                          const SizedBox(width: 12)
                        ],
                        Expanded(
                            child: Text(service?.name ?? booking.serviceId,
                                style:
                                    Theme.of(context).textTheme.titleMedium)),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.muted)
                      ]),
                      const SizedBox(height: 16),
                      Wrap(spacing: 12, runSpacing: 8, children: [
                        Text(dateLabel(booking.startAt),
                            style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w600)),
                        Text(
                            '${timeLabel(booking.startAt)}${service == null ? '' : ' · ${service.durationMinutes} phút'}')
                      ]),
                      const SizedBox(height: 12),
                      Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            StatusBadge(
                                statusLabel(booking.statusAt(DateTime.now())),
                                cancelled: booking.cancelled),
                            if (service != null)
                              Text(money(service.priceVnd),
                                  style: const TextStyle(
                                      color: AppColors.teal,
                                      fontWeight: FontWeight.w800))
                          ]),
                      const SizedBox(height: 8),
                      TextButton(
                          onPressed: () => openBookingDetail(
                              context, booking.id, widget.email),
                          child: const Text('Xem chi tiết & quản lý')),
                    ]))));
  }
}
