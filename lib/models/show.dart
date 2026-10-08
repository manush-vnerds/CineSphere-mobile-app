class Show {
  const Show({
    required this.id,
    required this.screenId,
    required this.startTime,
    required this.endTime,
    required this.bookedSeats,
    required this.isActive,
  });

  final String id;
  final String screenId;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> bookedSeats;
  final bool isActive;

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      id: json['_id'] as String? ?? '',
      screenId: json['screen_id'] as String? ?? '',
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      bookedSeats: (json['bookedSeats'] as List<dynamic>? ?? const [])
          .map((seat) => seat.toString())
          .toList(),
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}
