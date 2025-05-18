// lib/routes/routes.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apk_gizi/screens/splash/splash_screen.dart';
import 'package:apk_gizi/screens/auth/login_screen.dart';
import 'package:apk_gizi/screens/auth/register_screen.dart';
import 'package:apk_gizi/screens/home/home_screen.dart';
import 'package:apk_gizi/screens/biodata/biodata_screen.dart';
import 'package:apk_gizi/screens/kalkulator/kalkulator_screen.dart';
import 'package:apk_gizi/screens/hasil/hasil_screen.dart';
import 'package:apk_gizi/screens/jadwal/jadwal_screen.dart';
import 'package:apk_gizi/screens/history/history_screen.dart';
import 'package:apk_gizi/screens/profile/profile_screen.dart';

/// Singleton untuk token dan notify listener
class AuthService extends ChangeNotifier {
  AuthService._();
  static final instance = AuthService._();

  String? token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    notifyListeners();
  }

  Future<void> clear() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }
}

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: AuthService.instance,
    routes: [
      GoRoute(path: '/',       builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',  builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home',   builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/biodata',    builder: (_, __) => const BiodataScreen()),
      GoRoute(path: '/kalkulator', builder: (_, __) => const KalkulatorScreen()),
      GoRoute(
        path: '/hasil',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return HasilScreen(
            bmi: args['bmi'],
            statusBmi: args['statusBmi'],
            gender: args['gender'],
            age: args['age'],
            weight: args['weight'],
            height: args['height'],
            activity: args['activity'],
            goal: args['goal'],
          );
        },
      ),
      GoRoute(path: '/jadwal',  builder: (_, __) => const JadwalScreen()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
    redirect: (context, state) {
      final loggedIn  = AuthService.instance.token != null;
      final loggingIn = state.subloc == '/login' || state.subloc == '/register' || state.subloc == '/';
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn)  return '/home';
      return null;
    },
  );
}
