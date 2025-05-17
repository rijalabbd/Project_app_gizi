// lib/main.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';

/// Singleton untuk menyimpan `auth_token` di memory dan SharedPreferences
class AuthService extends ChangeNotifier {
  AuthService._();
  static final instance = AuthService._();

  String? token;

  /// Panggil sekali di main() sebelum runApp()
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    // tidak perlu notifyListeners di sini karena belum ada listener
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
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load token sekali sebelum UI jalan
  await AuthService.instance.loadToken();

  runApp(const ApkGiziApp());
}

class ApkGiziApp extends StatelessWidget {
  const ApkGiziApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/login',
      refreshListenable: AuthService.instance,  // ⚡️
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (_, __) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (_, __) => const HomeScreen(),
        ),
      ],
      redirect: (context, state) {
        final token = AuthService.instance.token;
        final loggingIn =
            state.subloc == '/login' || state.subloc == '/register';

        if (token == null && !loggingIn) {
          return '/login';
        }
        if (token != null && loggingIn) {
          return '/home';
        }
        return null;
      },
    );

    return MaterialApp.router(
      title: 'APK GIZI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
