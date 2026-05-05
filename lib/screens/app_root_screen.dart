import 'dart:async';

import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import 'login_screen.dart';
import 'shell_screen.dart';
import 'splash_screen.dart';

class AppRootScreen extends StatefulWidget {
  final AppController controller;

  const AppRootScreen({super.key, required this.controller});

  @override
  State<AppRootScreen> createState() => _AppRootScreenState();
}

class _AppRootScreenState extends State<AppRootScreen> {
  Timer? _timer;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: KeyedSubtree(
        key: ValueKey('$_showSplash-${widget.controller.isLoggedIn}'),
        child: _showSplash
            ? const SplashScreen()
            : widget.controller.isLoggedIn
            ? ShellScreen(controller: widget.controller)
            : LoginScreen(controller: widget.controller),
      ),
    );
  }
}
