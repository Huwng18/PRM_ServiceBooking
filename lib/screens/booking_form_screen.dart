import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/service_visual.dart';
import 'services_screen.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key, required this.service});

  final Service service;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTime? _date;
  TimeOfDay? _time;
  final _note = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (result != null && mounted) setState(() => _date = result);
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (result != null && mounted) setState(() => _time = result);
  }

  Future<void> _submit() async {
    if (_date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy chọn ngày và giờ.')),
      );
      return;
    }
    setState(() => busy = true);
    final startAt = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    final email = context.read<AuthProvider>().email!;
    final error = await context.read<BookingProvider>().book(
          userEmail: email,
          service: widget.service,
          startAt: startAt,
          note: _note.text.trim(),
        );
    if (!mounted) return;
    setState(() => busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Đặt lịch thành công!')),
    );
    if (error == null) Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Đặt lịch')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const Text('MỘT CHÚT NỮA THÔI',
              style: TextStyle(
                color: AppColors.teal,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.2,
              )),
          const SizedBox(height: 7),
          Text('Chọn lịch phù hợp\nvới bạn', style: textTheme.headlineMedium),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                ServiceIcon(service: widget.service, size: 60),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.service.name, style: textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                        '${widget.service.durationMinutes} phút  •  ${money(widget.service.priceVnd)}',
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 13)),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const _SectionTitle(number: '01', title: 'Ngày & giờ hẹn'),
          const SizedBox(height: 12),
          _PickerTile(
            icon: Icons.calendar_today_rounded,
            label: 'Ngày hẹn',
            value: _date == null
                ? 'Chọn ngày phù hợp'
                : '${_date!.day.toString().padLeft(2, '0')}/${_date!.month.toString().padLeft(2, '0')}/${_date!.year}',
            selected: _date != null,
            onTap: _pickDate,
          ),
          const SizedBox(height: 10),
          _PickerTile(
            icon: Icons.schedule_rounded,
            label: 'Giờ hẹn',
            value: _time == null ? 'Chọn giờ phù hợp' : _time!.format(context),
            selected: _time != null,
            onTap: _pickTime,
          ),
          const SizedBox(height: 11),
          const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.muted),
              SizedBox(width: 7),
              Text('Giờ phục vụ: 08:00–18:00',
                  style: TextStyle(color: AppColors.muted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 26),
          const _SectionTitle(number: '02', title: 'Ghi chú của bạn'),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: Tôi muốn đặt lịch vào buổi sáng...',
              helperText: 'Không bắt buộc',
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
          child: FilledButton.icon(
            onPressed: busy ? null : _submit,
            icon: busy
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_circle_outline_rounded, size: 20),
            label: Text(busy ? 'Đang lưu...' : 'Xác nhận đặt lịch'),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.number, required this.title});

  final String number;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 33,
            height: 33,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(number,
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                )),
          ),
          const SizedBox(width: 10),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      );
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: AppColors.teal, size: 20),
                ),
                const SizedBox(width: 13),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        )),
                    const SizedBox(height: 2),
                    Text(value,
                        style: TextStyle(
                          color: selected ? AppColors.ink : AppColors.muted,
                          fontSize: 15,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        )),
                  ],
                )),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
        ),
      );
}
