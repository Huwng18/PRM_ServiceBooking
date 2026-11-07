import '../models/service.dart';

const demoServices = <Service>[
  Service(
      id: 'hair',
      name: 'Cắt tóc & tạo kiểu',
      category: 'Làm đẹp',
      description: 'Tư vấn kiểu tóc và cắt tạo kiểu cơ bản.',
      durationMinutes: 45,
      priceVnd: 120000),
  Service(
      id: 'clean',
      name: 'Vệ sinh máy lạnh',
      category: 'Gia đình',
      description: 'Vệ sinh máy lạnh gia đình theo lịch hẹn.',
      durationMinutes: 90,
      priceVnd: 250000),
  Service(
      id: 'repair',
      name: 'Kiểm tra laptop',
      category: 'Công nghệ',
      description: 'Kiểm tra lỗi ban đầu và tư vấn phương án sửa chữa.',
      durationMinutes: 60,
      priceVnd: 150000),
  Service(
      id: 'consult',
      name: 'Tư vấn kỹ năng học tập',
      category: 'Giáo dục',
      description: 'Buổi tư vấn và lập kế hoạch học tập cá nhân.',
      durationMinutes: 60,
      priceVnd: 100000),
];
