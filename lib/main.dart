import 'package:flutter/material.dart';
import 'package:apk_gizi/routes/app_routes.dart';
import 'package:apk_gizi/services/auth_service.dart'; // Impor AuthService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.loadToken(); // Pastikan ini menginisialisasi token
  runApp(const ApkGiziApp());
}

class ApkGiziApp extends StatelessWidget {
  const ApkGiziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'APK Gizi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      routerConfig: AppRoutes.router,
    );
  }
}