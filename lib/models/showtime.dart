class Showtime {
  final String id;
  final String time;
  final String screen;
  final String price;
  final String availability;
  final String format;
  final String language;
  final String dateLabel;

  const Showtime({
    required this.id,
    required this.time,
    required this.screen,
    required this.price,
    required this.availability,
    required this.format,
    required this.language,
    required this.dateLabel,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    return Showtime(
      id: json['id']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      screen: json['screen']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      availability: json['availability']?.toString() ?? '',
      format: json['format']?.toString() ?? '2D',
      language: json['language']?.toString() ?? 'Phụ đề',
      dateLabel: json['dateLabel']?.toString() ?? 'Hôm nay',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'screen': screen,
      'price': price,
      'availability': availability,
      'format': format,
      'language': language,
      'dateLabel': dateLabel,
    };
  }
}
