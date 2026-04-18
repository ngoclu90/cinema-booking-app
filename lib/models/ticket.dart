class Ticket {
  final String id;
  final String movieTitle;
  final String cinemaName;
  final String screen;
  final String seat;
  final String date;
  final String time;
  final String status;
  final String ticketCode;
  final String price;
  final String snackCombo;
  final String hallType;
  final String gate;
  final String qrHint;

  const Ticket({
    required this.id,
    required this.movieTitle,
    required this.cinemaName,
    required this.screen,
    required this.seat,
    required this.date,
    required this.time,
    required this.status,
    required this.ticketCode,
    required this.price,
    required this.snackCombo,
    required this.hallType,
    required this.gate,
    required this.qrHint,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id']?.toString() ?? '',
      movieTitle: json['movieTitle']?.toString() ?? '',
      cinemaName: json['cinemaName']?.toString() ?? '',
      screen: json['screen']?.toString() ?? '',
      seat: json['seat']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      ticketCode: json['ticketCode']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      snackCombo: json['snackCombo']?.toString() ?? '',
      hallType: json['hallType']?.toString() ?? '',
      gate: json['gate']?.toString() ?? '',
      qrHint: json['qrHint']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieTitle': movieTitle,
      'cinemaName': cinemaName,
      'screen': screen,
      'seat': seat,
      'date': date,
      'time': time,
      'status': status,
      'ticketCode': ticketCode,
      'price': price,
      'snackCombo': snackCombo,
      'hallType': hallType,
      'gate': gate,
      'qrHint': qrHint,
    };
  }
}
