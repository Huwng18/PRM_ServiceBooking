import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../models/booking.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/app_navigation.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/service_visual.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen(
      {super.key, required this.service, this.existingBooking});
  final Service service;
  final Booking? existingBooking;
  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  late DateTime _date;
  DateTime? _selected;
  final _note = TextEditingController();
  bool _busy = false;
  String? _error;
  bool get _editing => widget.existingBooking != null;
  @override
  void initState() {
    super.initState();
    final old = widget.existingBooking;
    _date = DateUtils.dateOnly(old?.startAt ?? DateTime.now());
    _selected = old?.startAt;
    _note.text = old?.note ?? '';
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _changeDate(DateTime date) => setState(() {
        _date = date;
        _selected = null;
        _error = null;
      });
  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initial = _date.isBefore(today) ? today : _date;
    final last = today.add(const Duration(days: 365));
    final date = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: today,
        lastDate: initial.isAfter(last) ? initial : last);
    if (date != null && mounted) _changeDate(date);
  }

  String? _issue(DateTime time, BookingProvider provider, String email) =>
      BookingRules.validate(
          startAt: time,
          durationMinutes: widget.service.durationMinutes,
          existing: provider.all,
          userEmail: email,
          serviceId: widget.service.id,
          excludeBookingId: widget.existingBooking?.id);
  Future<void> _submit() async {
    if (_busy || _selected == null) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    if (auth.email == null) return;
    final provider = context.read<BookingProvider>();
    setState(() {
      _busy = true;
      _error = null;
    });
    final issue = _editing
        ? await provider.reschedule(
            id: widget.existingBooking!.id,
            userEmail: auth.email!,
            startAt: _selected!,
            note: _note.text)
        : await provider.book(
            userEmail: auth.email!,
            service: widget.service,
            startAt: _selected!,
            note: _note.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = issue;
    });
    if (issue == null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => BookingSuccessScreen(
                  service: widget.service,
                  startAt: _selected!,
                  rescheduled: _editing)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final email = context.watch<AuthProvider>().email ?? '';
    final today = DateUtils.dateOnly(DateTime.now());
    final selectedIssue =
        _selected == null ? null : _issue(_selected!, provider, email);
    return PopScope(
        canPop: !_busy,
        child: Scaffold(
          appBar: AppBar(
              title: Text(_editing ? 'Đổi lịch hẹn' : 'Đặt lịch dịch vụ')),
          body: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                SurfaceCard(
                    child: Row(children: [
                  ServiceIcon(service: widget.service, size: 52),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(widget.service.name,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                            '${widget.service.durationMinutes} phút · ${money(widget.service.priceVnd)}')
                      ]))
                ])),
                SectionHeader('01 · Ngày hẹn',
                    action: TextButton.icon(
                        onPressed: _busy ? null : _pickDate,
                        icon:
                            const Icon(Icons.calendar_today_outlined, size: 18),
                        label: const Text('Mở lịch'))),
                Text('Đã chọn: ${dateLabel(_date)}'),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (index) {
                      final day = today.add(Duration(days: index));
                      return ChoiceChip(
                          label: Text(index == 0
                              ? 'Hôm nay'
                              : index == 1
                                  ? 'Ngày mai'
                                  : '${day.day}/${day.month}'),
                          selected: DateUtils.isSameDay(_date, day),
                          onSelected: _busy ? null : (_) => _changeDate(day));
                    })),
                const SectionHeader('02 · Giờ hẹn',
                    subtitle: 'Giờ phục vụ 08:00–18:00 · bước 30 phút'),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(20, (index) {
                      final slot = DateTime(_date.year, _date.month, _date.day,
                          8 + index ~/ 2, (index % 2) * 30);
                      final issue = _issue(slot, provider, email);
                      return Tooltip(
                          message: issue ?? 'Chọn ${timeLabel(slot)}',
                          triggerMode: TooltipTriggerMode.tap,
                          child: ChoiceChip(
                              label: Text(timeLabel(slot)),
                              selected: _selected == slot,
                              onSelected: _busy || issue != null
                                  ? null
                                  : (_) => setState(() {
                                        _selected = slot;
                                        _error = null;
                                      })));
                    })),
                const SizedBox(height: 12),
                const Text(
                    'Giờ mờ: đã qua, trùng lịch cùng dịch vụ của bạn hoặc không đủ thời lượng trước 18:00. Chạm để xem lý do. Đây là lịch demo cục bộ, không phải chỗ trống của nhà cung cấp.',
                    style: TextStyle(fontSize: 12)),
                if (_selected != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                          selectedIssue ??
                              'Dự kiến kết thúc lúc ${timeLabel(_selected!.add(Duration(minutes: widget.service.durationMinutes)))}',
                          style: TextStyle(
                              color: selectedIssue == null
                                  ? AppColors.teal
                                  : AppColors.coral))),
                const SectionHeader('03 · Ghi chú', subtitle: 'Không bắt buộc'),
                TextField(
                    controller: _note,
                    enabled: !_busy,
                    maxLines: 3,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                        hintText: 'Bạn muốn nhắn thêm điều gì?')),
                const SectionHeader('04 · Xác nhận'),
                const SurfaceCard(
                    color: AppColors.mint,
                    child: Text(
                        'Lịch được lưu trên thiết bị. Bạn có thể đổi hoặc hủy trước giờ hẹn. Chưa có thanh toán thật.')),
                if (_error != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_error!,
                          style: const TextStyle(color: AppColors.coral))),
                if (provider.error != null)
                  AppEmptyState(
                      icon: Icons.error_outline,
                      title: 'Chưa thể tải lịch hẹn',
                      message: provider.error!,
                      action: OutlinedButton(
                          onPressed: provider.initialize,
                          child: const Text('Thử lại'))),
              ]),
          bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 16,
                            runSpacing: 4,
                            children: [
                              Text(_selected == null
                                  ? 'Chọn ngày và giờ phù hợp'
                                  : '${dateLabel(_selected!)} · ${timeLabel(_selected!)}'),
                              Text(money(widget.service.priceVnd),
                                  style: const TextStyle(
                                      color: AppColors.teal,
                                      fontWeight: FontWeight.w800))
                            ]),
                        const SizedBox(height: 10),
                        PrimaryButton(
                            label: _editing
                                ? 'Xác nhận đổi lịch'
                                : 'Xác nhận đặt lịch',
                            busy: _busy,
                            icon: Icons.check_rounded,
                            onPressed: _selected == null ||
                                    selectedIssue != null ||
                                    provider.loading ||
                                    provider.saving ||
                                    provider.error != null
                                ? null
                                : _submit),
                      ]))),
        ));
  }
}

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen(
      {super.key,
      required this.service,
      required this.startAt,
      this.rescheduled = false});
  final Service service;
  final DateTime startAt;
  final bool rescheduled;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Lịch hẹn của bạn')),
        body: SafeArea(
            child: ListView(padding: const EdgeInsets.all(24), children: [
          const SizedBox(height: 24),
          const Center(
              child: CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.mint,
                  child: Icon(Icons.check_rounded,
                      color: AppColors.teal, size: 36))),
          const SizedBox(height: 20),
          Text(rescheduled ? 'Đã đổi lịch hẹn!' : 'Đặt lịch thành công!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Một khoảng thời gian dành riêng cho bạn.',
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SurfaceCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(service.name,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Text('${dateLabel(startAt)} · ${timeLabel(startAt)}'),
                const SizedBox(height: 8),
                Text(
                    '${service.durationMinutes} phút · ${money(service.priceVnd)}'),
              ])),
          const SizedBox(height: 24),
          PrimaryButton(
              label: 'Xem lịch hẹn',
              icon: Icons.calendar_month_rounded,
              onPressed: () {
                context.read<AppNavigation>().select(1);
                Navigator.popUntil(context, (route) => route.isFirst);
              }),
          const SizedBox(height: 12),
          const Text('Đã lưu cục bộ · Chưa có xác nhận từ nhà cung cấp',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ])),
      );
}
