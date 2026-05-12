import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'success_screen.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebViewScreen({super.key, required this.paymentUrl});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(onNavigationRequest: _handleNavigation),
        )
        ..loadRequest(Uri.parse(widget.paymentUrl));
    }
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    const callbackPrefix = 'http://localhost:3000/payment-result';
    if (request.url.startsWith(callbackPrefix)) {
      final uri = Uri.tryParse(request.url);

      // Parse query params safely for downstream screen.
      final status = uri?.queryParameters['status'] ?? '';
      final orderId = uri?.queryParameters['orderId'] ?? '';
      final bookingCode = uri?.queryParameters['bookingCode'] ?? '';
      final movieName = uri?.queryParameters['movieName'] ?? '';
      final seatList = uri?.queryParameters['seatList'] ?? '';
      final totalPrice = uri?.queryParameters['totalPrice'] ?? '';

      final navigator = Navigator.of(context);
      navigator.pop();

      if (status == 'success') {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => SuccessScreen(
              status: status,
              orderId: orderId,
              bookingCode: bookingCode,
              movieName: movieName,
              seatList: seatList,
              totalPrice: totalPrice,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(navigator.context).showSnackBar(
          const SnackBar(
            content: Text('Thanh toán thất bại. Vui lòng thử lại.'),
          ),
        );
      }

      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Đóng',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: kIsWeb ? _buildWebFallback(context) : _buildWebView(),
    );
  }

  Widget _buildWebView() {
    final controller = _controller;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return WebViewWidget(controller: controller);
  }

  Widget _buildWebFallback(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trinh duyet web khong ho tro WebView. Mo trang thanh toan o tab moi.',
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _openExternalPaymentUrl,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Mo trang thanh toan'),
          ),
        ],
      ),
    );
  }

  Future<void> _openExternalPaymentUrl() async {
    final uri = Uri.tryParse(widget.paymentUrl);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
