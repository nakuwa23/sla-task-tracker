import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        ...super.dragDevices,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

void main() {
  runApp(const SlaTaskTrackerApp());
}

class SlaTaskTrackerApp extends StatelessWidget {
  const SlaTaskTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SLA Task Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scrollBehavior: _AppScrollBehavior(),
      home: const SplashScreen(),
    );
  }
}