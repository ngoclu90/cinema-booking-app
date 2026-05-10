import 'dart:io';
import 'package:flutter/foundation.dart';

class ImageHelper {
  static String get _host {
    if (kIsWeb) return "localhost";
    if (Platform.isAndroid) {
      return "192.168.123.7";
    }
    return "localhost";
  }

  static const String _port = "8080";

  static String getCorrectImageUrl(String? posterUrl) {
    if (posterUrl == null || posterUrl.trim().isEmpty) {
      return "assets/images/placeholder.png";
    }

    String raw = posterUrl.trim();

    if (raw.startsWith("http://") || raw.startsWith("https://")) {
      if (raw.contains("localhost") || raw.contains("127.0.0.1")) {
        return raw.replaceAll('localhost', _host).replaceAll('127.0.0.1', _host);
      }
      return raw;
    }

    String cleanPath = raw;
    if (!cleanPath.startsWith('media/') && !cleanPath.startsWith('/media/')) {
      cleanPath = 'media/$cleanPath';
    }

    cleanPath = cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath;

    final finalUrl = "http://$_host:$_port/$cleanPath";

    debugPrint('Final Image URL: $finalUrl');

    return finalUrl;
  }
}