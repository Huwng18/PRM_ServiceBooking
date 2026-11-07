import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

String money(int amount) =>
    '${amount.toString().replaceAllMapped(RegExp(r'(?<=\d)(?=(?:\d{3})+$)'), (m) => '.')} đ';
String dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
String timeLabel(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: AppColors.teal, borderRadius: BorderRadius.circular(12)),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 22)),
        const SizedBox(width: 8),
        Text('hẹnio.',
            textScaler: TextScaler.noScaling,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(letterSpacing: -1)),
      ]);
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.subtitle, this.action});
  final String title;
  final String? subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!)
                ],
              ])),
          if (action != null) action!
        ]),
      );
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard(
      {super.key,
      required this.child,
      this.color = Colors.white,
      this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Material(
        color: color,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.line)),
        child: Padding(padding: padding, child: child),
      );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.cancelled = false});
  final String label;
  final bool cancelled;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: cancelled ? AppColors.peach : AppColors.mint,
            borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: TextStyle(
                color: cancelled ? AppColors.coral : AppColors.teal,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      );
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.message,
      this.action});
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.mint,
              child: Icon(icon, size: 28, color: AppColors.teal)),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ]),
      );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
      {super.key,
      required this.label,
      this.onPressed,
      this.busy = false,
      this.icon = Icons.arrow_forward_rounded});
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData icon;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
        onPressed: busy ? null : onPressed,
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(icon, size: 20),
        label: Text(busy ? 'Đang lưu…' : label, textAlign: TextAlign.center),
      );
}
