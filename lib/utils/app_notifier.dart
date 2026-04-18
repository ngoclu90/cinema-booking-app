import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AppNotifier {
  static void info(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    _show(
      context,
      title: title,
      description: description,
      type: ToastificationType.info,
    );
  }

  static void success(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    _show(
      context,
      title: title,
      description: description,
      type: ToastificationType.success,
    );
  }

  static void warning(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    _show(
      context,
      title: title,
      description: description,
      type: ToastificationType.warning,
    );
  }

  static void _show(
    BuildContext context, {
    required String title,
    required String description,
    required ToastificationType type,
  }) {
    toastification.show(
      context: context,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      type: type,
      style: ToastificationStyle.flatColored,
      title: Text(title),
      description: Text(description),
    );
  }
}
