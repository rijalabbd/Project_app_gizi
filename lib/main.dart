// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const APKGiziApp());
}

class APKGiziApp extends StatelessWidget {
  const APKGiziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'APK GIZI',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
    );
  }
}
