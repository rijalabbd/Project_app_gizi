// lib/main.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/biodata/biodata_screen.dart';
import 'screens/kalkulator/kalkulator_screen.dart';
import 'screens/hasil/hasil_screen.dart';
import 'screens/jadwal/jadwal_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/profile/profile_screen.dart';

/// Singleton untuk menyimpan `auth_token` dan memberi tahu GoRouter saat berubah.
class AuthService extends ChangeNotifier {
  AuthService._();
  static final instance = AuthService._();

  String? token;

  /// Panggil sekali di main() sebelum runApp()
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    notifyListeners(); // biar GoRouter cek ulang redirect setelah startup
  }

  /// Simpan token (dipanggil di LoginScreen)
  Future<void> saveToken(String newToken) async {
    token = newToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', newToken);
    notifyListeners(); // beri tahu GoRouter untuk re-evaluate redirect
  }

  /// Hapus token (dipanggil di HomeScreen saat logout)
  Future<void> clear() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners(); // beri tahu GoRouter untuk re-evaluate redirect
  }
}

late final GoRouter _appRouter;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Muat token sebelum UI mulai, lalu beri tahu GoRouter
  await AuthService.instance.loadToken();

  // Definisikan GoRouter
  _appRouter = GoRouter(
    initialLocation: '/',                    // SplashScreen
    refreshListenable: AuthService.instance, // listen perubahan AuthService.token
    routes: [
      GoRoute(path: '/',       builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',  builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home',   builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/biodata',    builder: (_, __) => const BiodataScreen()),
      GoRoute(path: '/kalkulator', builder: (_, __) => const KalkulatorScreen()),
      GoRoute(
        path: '/hasil',
        builder: (ctx, state) {
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
      final loggingIn = state.subloc == '/login' ||
                        state.subloc == '/register' ||
                        state.subloc == '/';
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn)  return '/home';
      return null;
    },
  );

  runApp(const ApkGiziApp());
}

class ApkGiziApp extends StatelessWidget {
  const ApkGiziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'APK GIZI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      routerConfig: _appRouter,
    );
  }
}
