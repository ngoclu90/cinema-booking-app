import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebViewScreen({super.key, required this.paymentUrl});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  WebViewController? _controller;
  static const String _legacyCallbackPrefix =
      'http://localhost:3000/payment-result';

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
    final uri = Uri.tryParse(request.url);
    if (uri == null) {
      return NavigationDecision.navigate;
    }

    if (_isPaymentCallback(uri)) {
      unawaited(_handlePaymentResult(uri));
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  bool _isPaymentCallback(Uri uri) {
    final url = uri.toString();
    if (url.startsWith(_legacyCallbackPrefix)) {
      return true;
    }

    final path = uri.path.toLowerCase();
    return path.contains('/payment') && path.contains('/return');
  }

  bool _isPaymentSuccess(Uri uri) {
    final status = uri.queryParameters['status']?.toLowerCase();
    if (status == 'success') return true;

    final resultCode = uri.queryParameters['resultCode'];
    if (resultCode == '0' || resultCode == '00') return true;

    final vnpResponseCode = uri.queryParameters['vnp_ResponseCode'];
    if (vnpResponseCode == '00') return true;

    final vnpTransactionStatus = uri.queryParameters['vnp_TransactionStatus'];
    if (vnpTransactionStatus == '00') return true;

    return false;
  }

  Future<void> _handlePaymentResult(Uri uri) async {
    final success = _isPaymentSuccess(uri);

    await _controller?.clearCache();
    await _controller?.clearLocalStorage();

    if (!mounted) return;

    final navigator = Navigator.of(context);
    if (success) {
      navigator.popUntil((route) => route.isFirst);
      return;
    }

    navigator.pop();
    ScaffoldMessenger.of(navigator.context).showSnackBar(
      const SnackBar(
        content: Text('Thanh toán thất bại. Vui lòng thử lại.'),
      ),
    );
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
