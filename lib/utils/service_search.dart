import '../models/service.dart';

String normalizeSearch(String input) {
  var text = input.toLowerCase().trim();
  const groups = {
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };
  groups.forEach((base, variants) {
    for (final rune in variants.runes) {
      text = text.replaceAll(String.fromCharCode(rune), base);
    }
  });
  return text
      .replaceAll(RegExp(r'[\u0300-\u036f]'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
}

List<Service> filterServices(Iterable<Service> services,
    {String query = '',
    String category = 'Tất cả',
    int? minPrice,
    int? maxPrice,
    int sort = 0}) {
  final words = normalizeSearch(query).split(' ').where((w) => w.isNotEmpty);
  final result = services.where((s) {
    final haystack =
        normalizeSearch('${s.name} ${s.category} ${s.description}');
    return (category == 'Tất cả' || category == s.category) &&
        (minPrice == null || s.priceVnd >= minPrice) &&
        (maxPrice == null || s.priceVnd <= maxPrice) &&
        words.every(haystack.contains);
  }).toList();
  if (sort != 0) {
    result.sort((a, b) => sort * a.priceVnd.compareTo(b.priceVnd));
  }
  return result;
}
