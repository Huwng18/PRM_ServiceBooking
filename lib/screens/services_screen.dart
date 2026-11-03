import 'package:flutter/material.dart';
import '../data/demo_services.dart';
import '../models/service.dart';
import '../theme/app_theme.dart';
import '../widgets/service_visual.dart';
import 'service_detail_screen.dart';

String money(int amount) =>
    '${amount.toString().replaceAllMapped(RegExp(r'(?<=\d)(?=(?:\d{3})+$)'), (m) => '.')} đ';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String _query = '';
  String _category = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    const categories = [
      'Tất cả',
      'Làm đẹp',
      'Gia đình',
      'Công nghệ',
      'Giáo dục'
    ];
    final items = demoServices.where((service) {
      final matchesCategory =
          _category == 'Tất cả' || service.category == _category;
      final matchesQuery = '${service.name} ${service.category}'
          .toLowerCase()
          .contains(_query.trim().toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          const _WelcomeHero(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm dịch vụ bạn cần...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.teal),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 8),
            child: Row(
              children: [
                Expanded(
                    child: Text('Khám phá dịch vụ',
                        style: Theme.of(context).textTheme.headlineSmall)),
                Text('${items.length} dịch vụ',
                    style: const TextStyle(
                        color: AppColors.muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = category == _category;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  showCheckmark: false,
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.ink,
                  side: BorderSide(
                      color: selected ? AppColors.ink : AppColors.line),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => setState(() => _category = category),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const _EmptyServices()
          else
            for (final service in items)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _ServiceCard(service: service),
              ),
        ],
      ),
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.ink, Color(0xFF0B6965)],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                top: -62,
                right: -58,
                child: Container(
                  height: 194,
                  width: 194,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.07)),
                ),
              ),
              Positioned(
                bottom: -93,
                right: 48,
                child: Container(
                  height: 165,
                  width: 165,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded,
                              size: 20, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const Text('SERVICE BOOKING',
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            )),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Mọi dịch vụ,\ntrong tầm tay.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          height: 1.13,
                          letterSpacing: -0.7,
                          fontWeight: FontWeight.w800,
                        )),
                    const SizedBox(height: 11),
                    Text('Chọn dịch vụ phù hợp và đặt lịch chỉ trong vài bước.',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 13,
                            height: 1.45)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final Service service;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ServiceDetailScreen(service: service))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    ServiceIcon(service: service),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(service.category,
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 13)),
                      ],
                    )),
                    const Icon(Icons.arrow_outward_rounded,
                        color: AppColors.muted, size: 20),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, color: AppColors.line),
                ),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 17, color: AppColors.muted),
                    const SizedBox(width: 5),
                    Text('${service.durationMinutes} phút',
                        style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text(money(service.priceVnd),
                        style: const TextStyle(
                            color: AppColors.teal,
                            fontSize: 17,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

class _EmptyServices extends StatelessWidget {
  const _EmptyServices();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        child: Column(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: const BoxDecoration(
                color: AppColors.mint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  color: AppColors.teal, size: 34),
            ),
            const SizedBox(height: 14),
            Text('Chưa tìm thấy dịch vụ',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            const Text('Thử một từ khóa hoặc danh mục khác.',
                style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );
}
