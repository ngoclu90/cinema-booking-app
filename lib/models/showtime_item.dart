class ShowtimeItemDto {
  final int id;
  final String showTime;
  final String? roomName;
  final double? price;
  final String? format;
  final String? language;

  ShowtimeItemDto({
    required this.id,
    required this.showTime,
    this.roomName,
    this.price,
    this.format,
    this.language,
  });

  factory ShowtimeItemDto.fromJson(Map<String, dynamic> json) {
    return ShowtimeItemDto(
      id: json['id'] as int? ?? 0,
      showTime: (json['startTime'] ?? json['showTime'] ?? '').toString(),
      roomName: json['roomName']?.toString(),
      price: (json['price'] as num?)?.toDouble(),
      format: (json['type'] ?? json['format'])?.toString(),
      language: json['language']?.toString(),
    );
  }
}

class MovieWithShowtimesDto {
  final int cinemaId;
  final String cinemaName;
  final String? address;
  final String? cinemaImageUrl;
  final String? posterUrl;
  final int? durationMinutes;
  final List<ShowtimeItemDto> showtimes;

  MovieWithShowtimesDto({
    required this.cinemaId,
    required this.cinemaName,
    this.address,
    this.cinemaImageUrl,
    this.posterUrl,
    this.durationMinutes,
    required this.showtimes,
  });

  factory MovieWithShowtimesDto.fromJson(Map<String, dynamic> json) {
    final rawList = json['showtimes'] ?? json['showtime'] ?? [];
    final List<dynamic> list = rawList is List ? rawList : [];

    return MovieWithShowtimesDto(
      cinemaId: json['cinemaId'] as int? ?? 0,
      cinemaName: json['cinemaName']?.toString() ?? '',
      address: json['address']?.toString(),
      cinemaImageUrl: json['cinemaImageUrl']?.toString(),
      posterUrl: json['posterUrl']?.toString(),
      durationMinutes: json['durationMinutes'] as int?,
      showtimes: list
          .map((item) => ShowtimeItemDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}