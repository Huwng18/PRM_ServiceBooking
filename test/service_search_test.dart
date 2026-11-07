import 'package:flutter_test/flutter_test.dart';
import 'package:service_booking_flutter/data/demo_services.dart';
import 'package:service_booking_flutter/utils/service_search.dart';

void main() {
  test('Vietnamese search supports accents, casing and separate words', () {
    expect(filterServices(demoServices, query: '  CAT TOC ').single.id, 'hair');
    expect(filterServices(demoServices, query: 'VỆ SINH').single.id, 'clean');
    expect(filterServices(demoServices, query: 'hoc ky').single.id, 'consult');
    expect(normalizeSearch('ĐẶT LỊCH'), 'dat lich');
  });
  test('category and price combine and sorting is deterministic', () {
    expect(filterServices(demoServices, category: 'Làm đẹp', minPrice: 150000),
        isEmpty);
    expect(
        filterServices(demoServices, minPrice: 150000, maxPrice: 200000)
            .single
            .id,
        'repair');
    expect(filterServices(demoServices, sort: 1).map((s) => s.id),
        ['consult', 'hair', 'repair', 'clean']);
    expect(filterServices(demoServices, sort: -1).first.id, 'clean');
  });
}
