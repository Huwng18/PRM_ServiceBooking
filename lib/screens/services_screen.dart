import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/demo_services.dart';
import '../providers/app_navigation.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/service_search.dart';
import '../widgets/app_components.dart';
import '../widgets/service_card.dart';

import 'notifications_screen.dart';

export '../widgets/app_components.dart' show money;

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});
  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _search = TextEditingController();
  final _results = GlobalKey();
  String _category = 'Tất cả';
  int _price = 0;
  int _sort = 0;
  static const _prices = [
    'Mọi mức giá',
    'Dưới 150.000 đ',
    '150.000–200.000 đ',
    'Trên 200.000 đ'
  ];
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reset() => setState(() {
        _search.clear();
        _category = 'Tất cả';
        _price = 0;
        _sort = 0;
      });

  Future<void> _filters() async {
    var price = _price;
    var sort = _sort;
    final apply = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => StatefulBuilder(
            builder: (context, update) => SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Bộ lọc dịch vụ',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SectionHeader('Khoảng giá'),
                      Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                              _prices.length,
                              (i) => ChoiceChip(
                                  label: Text(_prices[i]),
                                  selected: price == i,
                                  onSelected: (_) => update(() => price = i)))),
                      const SectionHeader('Sắp xếp'),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final option in [
                          (0, 'Mặc định'),
                          (1, 'Giá tăng dần'),
                          (-1, 'Giá giảm dần')
                        ])
                          ChoiceChip(
                              label: Text(option.$2),
                              selected: sort == option.$1,
                              onSelected: (_) =>
                                  update(() => sort = option.$1)),
                      ]),
                      const SizedBox(height: 20),
                      PrimaryButton(
                          label: 'Áp dụng',
                          icon: Icons.check_rounded,
                          onPressed: () => Navigator.pop(context, true)),
                      TextButton(
                          onPressed: () => update(() {
                                price = 0;
                                sort = 0;
                              }),
                          child: const Text('Đặt lại bộ lọc')),
                    ]))));
    if (apply == true && mounted) {
      setState(() {
        _price = price;
        _sort = sort;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().email ?? '';
    final items = filterServices(demoServices,
        query: _search.text,
        category: _category,
        minPrice: _price == 2
            ? 150000
            : _price == 3
                ? 200001
                : null,
        maxPrice: _price == 1
            ? 149999
            : _price == 2
                ? 200000
                : null,
        sort: _sort);
    final filtered = _search.text.isNotEmpty ||
        _category != 'Tất cả' ||
        _price != 0 ||
        _sort != 0;
    return SafeArea(
        child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
          Row(children: [
            const Brand(),
            const Spacer(),
            IconButton.outlined(
                tooltip: 'Nhắc lịch của bạn',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen())),
                icon: const Icon(Icons.notifications_none_rounded)),
            const SizedBox(width: 8),
            IconButton.filledTonal(
                tooltip: 'Tài khoản',
                onPressed: () => context.read<AppNavigation>().select(3),
                icon: Text(email.isEmpty ? 'H' : email[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 20),
          const Text('Chào bạn, một ngày thật tốt lành'),
          const SizedBox(height: 4),
          Text('Hôm nay, bạn cần gì?',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(children: [
                Positioned.fill(
                    child: Image.asset('assets/images/forest.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const ColoredBox(color: AppColors.mint))),
                Positioned.fill(
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                  const Color(0xFFEBEFDF),
                  const Color(0xFFEBEFDF).withValues(alpha: .90),
                  const Color(0xFFEBEFDF).withValues(alpha: .25)
                ], stops: const [
                  0,
                  .55,
                  1
                ])))),
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CHĂM CHÚT CUỘC SỐNG',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.teal,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 10),
                          Text('Bớt bận rộn.\nThêm thảnh thơi.',
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          const Text('Dịch vụ bạn cần, vào lúc bạn muốn.',
                              style: TextStyle(
                                  color: AppColors.ink, fontSize: 13)),
                          const SizedBox(height: 12),
                          FilledButton(
                              onPressed: () => Scrollable.ensureVisible(
                                  _results.currentContext!,
                                  duration: const Duration(milliseconds: 350)),
                              child: const Text('Khám phá ngay')),
                        ])),
              ])),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                        hintText: 'Tìm dịch vụ bạn đang cần…',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Xóa tìm kiếm',
                                onPressed: () => setState(_search.clear),
                                icon: const Icon(Icons.close_rounded))))),
            const SizedBox(width: 8),
            IconButton.outlined(
                tooltip: 'Bộ lọc',
                onPressed: _filters,
                icon: Badge(
                    isLabelVisible: _price != 0 || _sort != 0,
                    child: const Icon(Icons.tune_rounded))),
          ]),
          const SizedBox(height: 12),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final category in [
                  'Tất cả',
                  ...demoServices.map((s) => s.category).toSet()
                ])
                  Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                          showCheckmark: false,
                          label: Text(category),
                          selected: _category == category,
                          onSelected: (_) =>
                              setState(() => _category = category))),
              ])),
          if (filtered)
            Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (_category != 'Tất cả')
                    InputChip(
                        label: Text(_category),
                        onDeleted: () => setState(() => _category = 'Tất cả')),
                  if (_price != 0)
                    InputChip(
                        label: Text(_prices[_price]),
                        onDeleted: () => setState(() => _price = 0)),
                  if (_sort != 0)
                    InputChip(
                        label:
                            Text(_sort == 1 ? 'Giá tăng dần' : 'Giá giảm dần'),
                        onDeleted: () => setState(() => _sort = 0)),
                  TextButton(
                      onPressed: _reset, child: const Text('Xóa bộ lọc')),
                ]),
          SectionHeader(
              key: _results,
              titleText,
              subtitle: 'Một chút chăm sóc, một ngày tốt hơn.',
              action: Text('${items.length} dịch vụ',
                  style: const TextStyle(fontSize: 12, color: AppColors.teal))),
          if (items.isEmpty)
            AppEmptyState(
                icon: Icons.search_off_rounded,
                title: 'Chưa tìm thấy dịch vụ',
                message: 'Thử từ khóa khác hoặc điều chỉnh bộ lọc.',
                action: OutlinedButton(
                    onPressed: _reset, child: const Text('Xóa bộ lọc'))),
          LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth >= 650 ? 2 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
            return Wrap(spacing: 16, runSpacing: 16, children: [
              for (final service in items)
                SizedBox(width: width, child: ServiceCard(service: service))
            ]);
          }),
          const SizedBox(height: 16),
          const Text('Danh mục demo · Ảnh chỉ mang tính minh họa',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ]));
  }

  String get titleText => 'Dành riêng cho bạn';
}
