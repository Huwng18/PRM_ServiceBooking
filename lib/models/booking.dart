class Booking {
  final String id;
  final String userEmail;
  final String serviceId;
  final DateTime startAt;
  final String note;
  final bool cancelled;
  const Booking({required this.id, required this.userEmail, required this.serviceId,
    required this.startAt, required this.note, this.cancelled = false});

  Booking cancel() => Booking(id: id, userEmail: userEmail, serviceId: serviceId,
      startAt: startAt, note: note, cancelled: true);

  Map<String, dynamic> toJson() => {'id': id, 'userEmail': userEmail,
    'serviceId': serviceId, 'startAt': startAt.toIso8601String(),
    'note': note, 'cancelled': cancelled};
  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as String, userEmail: json['userEmail'] as String,
    serviceId: json['serviceId'] as String,
    startAt: DateTime.parse(json['startAt'] as String),
    note: json['note'] as String? ?? '',
    cancelled: json['cancelled'] as bool? ?? false);
}
