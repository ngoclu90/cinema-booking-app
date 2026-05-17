class Ticket {
  final int id;
  final String code;
  final String movieTitle;
  final String moviePosterUrl;
  final String cinemaName;
  final String roomName;
  final String seatCodes;
  final String showTime;
  final String status;
  final double totalPrice;

  const Ticket({
    required this.id,
    required this.code,
    required this.movieTitle,
    required this.moviePosterUrl,
    required this.cinemaName,
    required this.roomName,
    required this.seatCodes,
    required this.showTime,
    required this.status,
    required this.totalPrice,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      code: json['bookingCode']?.toString() ?? json['code']?.toString() ?? '',
      movieTitle: json['movieTitle']?.toString() ?? 'Đang cập nhật...',
      moviePosterUrl: json['posterUrl']?.toString() ?? '',
      cinemaName: json['cinemaName']?.toString() ?? 'Rạp chiếu phim',
      roomName: json['roomName']?.toString() ?? 'Phòng chiếu',
      seatCodes: json['seats']?.toString() ?? json['seatCodes']?.toString() ?? '',
      showTime: json['startTime']?.toString() ?? json['showTime']?.toString() ?? '',
      status: json['status']?.toString() ?? 'UNKNOWN',
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'movieTitle': movieTitle,
    'moviePosterUrl': moviePosterUrl,
    'cinemaName': cinemaName,
    'roomName': roomName,
    'seatCodes': seatCodes,
    'showTime': showTime,
    'status': status,
    'totalPrice': totalPrice,
  };
}