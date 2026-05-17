class Seat {
  final int id;
  final String code;
  final String row;
  final String number;
  final String type;
  final String status;
  final double price;

  const Seat({
    required this.id,
    required this.code,
    required this.row,
    required this.number,
    required this.type,
    required this.status,
    required this.price,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      code: json['code']?.toString() ?? '',
      row: json['row']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      type: json['type']?.toString() ?? 'STANDARD',
      status: json['status']?.toString() ?? 'AVAILABLE',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'row': row,
    'number': number,
    'type': type,
    'status': status,
    'price': price,
  };
}

class SeatRow {
  final String rowLabel;
  final List<Seat> seats;

  const SeatRow({
    required this.rowLabel,
    required this.seats,
  });

  factory SeatRow.fromJson(Map<String, dynamic> json) {
    return SeatRow(
      rowLabel: json['rowLabel']?.toString() ?? '',
      seats: (json['seats'] as List<dynamic>?)
          ?.map((e) => Seat.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'rowLabel': rowLabel,
    'seats': seats.map((e) => e.toJson()).toList(),
  };
}

class ShowtimeSeatResponse {
  final int showtimeId;
  final String cinemaName;
  final List<SeatRow> rows;
  final String movieTitle;
  final String moviePosterUrl;
  final String genre;
  final int duration;
  final String roomName;
  final String fullAddress;
  final String? startTime;

  const ShowtimeSeatResponse({
    required this.showtimeId,
    required this.cinemaName,
    required this.rows,
    required this.movieTitle,
    required this.moviePosterUrl,
    required this.genre,
    required this.duration,
    required this.roomName,
    required this.fullAddress,
    this.startTime,
  });

  factory ShowtimeSeatResponse.fromJson(Map<String, dynamic> json) {
    return ShowtimeSeatResponse(
      showtimeId: json['showtimeId'] is int
          ? json['showtimeId']
          : int.tryParse(json['showtimeId']?.toString() ?? '0') ?? 0,
      cinemaName: json['cinemaName']?.toString() ?? '',
      rows: (json['seatMap'] as List<dynamic>?)
          ?.map((e) => SeatRow.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      movieTitle: json['movieTitle']?.toString() ?? '',
      moviePosterUrl: json['moviePosterUrl']?.toString() ?? '',
      genre: json['genre']?.toString() ?? '',
      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      roomName: json['roomName']?.toString() ?? '',
      fullAddress: json['fullAddress']?.toString() ?? '',
      startTime: json['startTime']?.toString(),
    );
  }
}

class SeatActionRequest {
  final int showtimeId;
  final List<int> seatIds;

  const SeatActionRequest({
    required this.showtimeId,
    required this.seatIds,
  });

  Map<String, dynamic> toJson() => {
    'showtimeId': showtimeId,
    'seatIds': seatIds,
  };
}

class SeatActionResponse {
  final bool isSuccess;
  final String message;

  const SeatActionResponse({
    required this.isSuccess,
    required this.message,
  });

  factory SeatActionResponse.fromJson(Map<String, dynamic> json) {
    return SeatActionResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message']?.toString() ?? '',
    );
  }
}