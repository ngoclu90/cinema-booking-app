class BookingCreateResponse {
  final String bookingCode;
  final int bookingId;
  final DateTime? createdAt;
  final int discountAmount;
  final String message;
  final String paymentMethod;
  final String paymentStatus;
  final String paymentUrl;
  final int showtimeId;
  final int totalPrice;
  final int userId;

  const BookingCreateResponse({
    required this.bookingCode,
    required this.bookingId,
    required this.createdAt,
    required this.discountAmount,
    required this.message,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentUrl,
    required this.showtimeId,
    required this.totalPrice,
    required this.userId,
  });

  factory BookingCreateResponse.fromJson(Map<String, dynamic> json) {
    return BookingCreateResponse(
      bookingCode: json['bookingCode']?.toString() ?? '',
      bookingId: (json['bookingId'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      discountAmount: (json['discountAmount'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      paymentUrl: json['paymentUrl']?.toString() ?? '',
      showtimeId: (json['showtimeId'] as num?)?.toInt() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
    );
  }
}
