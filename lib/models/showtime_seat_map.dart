class ShowtimeSeatMap {
  final String cinemaName;
  final int duration;
  final String fullAddress;
  final String genre;
  final String moviePosterUrl;
  final String movieTitle;
  final String roomName;
  final List<SeatRow> seatMap;
  final int showtimeId;
  final DateTime? startTime;

  const ShowtimeSeatMap({
    required this.cinemaName,
    required this.duration,
    required this.fullAddress,
    required this.genre,
    required this.moviePosterUrl,
    required this.movieTitle,
    required this.roomName,
    required this.seatMap,
    required this.showtimeId,
    required this.startTime,
  });

  factory ShowtimeSeatMap.fromJson(Map<String, dynamic> json) {
    final rawSeatMap = json['seatMap'] as List<dynamic>? ?? const [];
    return ShowtimeSeatMap(
      cinemaName: json['cinemaName']?.toString() ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      fullAddress: json['fullAddress']?.toString() ?? '',
      genre: json['genre']?.toString() ?? '',
      moviePosterUrl: json['moviePosterUrl']?.toString() ?? '',
      movieTitle: json['movieTitle']?.toString() ?? '',
      roomName: json['roomName']?.toString() ?? '',
      seatMap: rawSeatMap
          .map((item) => SeatRow.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      showtimeId: (json['showtimeId'] as num?)?.toInt() ?? 0,
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cinemaName': cinemaName,
      'duration': duration,
      'fullAddress': fullAddress,
      'genre': genre,
      'moviePosterUrl': moviePosterUrl,
      'movieTitle': movieTitle,
      'roomName': roomName,
      'seatMap': seatMap.map((row) => row.toJson()).toList(growable: false),
      'showtimeId': showtimeId,
      'startTime': startTime?.toIso8601String(),
    };
  }
}

class SeatRow {
  final String rowLabel;
  final List<SeatInfo> seats;

  const SeatRow({required this.rowLabel, required this.seats});

  factory SeatRow.fromJson(Map<String, dynamic> json) {
    final rawSeats = json['seats'] as List<dynamic>? ?? const [];
    return SeatRow(
      rowLabel: json['rowLabel']?.toString() ?? '',
      seats: rawSeats
          .map((item) => SeatInfo.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rowLabel': rowLabel,
      'seats': seats.map((seat) => seat.toJson()).toList(growable: false),
    };
  }
}

class SeatInfo {
  final int id;
  final String code;
  final String row;
  final String number;
  final String type;
  final String status;
  final int price;

  const SeatInfo({
    required this.id,
    required this.code,
    required this.row,
    required this.number,
    required this.type,
    required this.status,
    required this.price,
  });

  factory SeatInfo.fromJson(Map<String, dynamic> json) {
    return SeatInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString() ?? '',
      row: json['row']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'row': row,
      'number': number,
      'type': type,
      'status': status,
      'price': price,
    };
  }
}
