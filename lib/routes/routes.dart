import 'package:flutter/material.dart';
import 'package:apk_gizi/screens/splash/splash_screen.dart';
import 'package:apk_gizi/screens/auth/login_screen.dart';
import 'package:apk_gizi/screens/home/home_screen.dart';
import 'package:apk_gizi/screens/biodata/biodata_screen.dart';
import 'package:apk_gizi/screens/kalkulator/kalkulator_screen.dart';
import 'package:apk_gizi/screens/hasil/hasil_screen.dart';
import 'package:apk_gizi/screens/jadwal/jadwal_screen.dart';
import 'package:apk_gizi/screens/history/history_screen.dart';
import 'package:apk_gizi/screens/profile/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String biodata = '/biodata';
  static const String kalkulator = '/kalkulator';
  static const String hasil = '/hasil';
  static const String jadwal = '/jadwal';
  static const String history = '/history';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case biodata:
        return MaterialPageRoute(builder: (_) => const BiodataScreen());
      case kalkulator:
        return MaterialPageRoute(builder: (_) => const KalkulatorScreen());
      case hasil:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => HasilScreen(
            bmi: args['bmi'],
            statusBmi: args['statusBmi'],  // Correct key for 'statusBmi'
            gender: args['gender'],
            age: args['age'],
            weight: args['weight'],
            height: args['height'],
            activity: args['activity'],   // Correct key for 'activity'
            goal: args['goal'],
          ),
        );
      case jadwal:
        return MaterialPageRoute(builder: (_) => const JadwalScreen());
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Halaman tidak ditemukan')),
          ),
        );
    }
  }
}
