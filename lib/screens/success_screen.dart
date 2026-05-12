import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final String status;
  final String orderId;
  final String bookingCode;
  final String movieName;
  final String seatList;
  final String totalPrice;

  const SuccessScreen({
    super.key,
    required this.status,
    required this.orderId,
    required this.bookingCode,
    required this.movieName,
    required this.seatList,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán thành công')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SuccessScreen placeholder'),
            const SizedBox(height: 12),
            Text('status: $status'),
            Text('orderId: $orderId'),
            Text('bookingCode: $bookingCode'),
            Text('movieName: $movieName'),
            Text('seatList: $seatList'),
            Text('totalPrice: $totalPrice'),
          ],
        ),
      ),
    );
  }
}
