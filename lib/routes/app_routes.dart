import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:apk_gizi/services/auth_service.dart'; // Impor AuthService
import 'package:apk_gizi/screens/splash/splash_screen.dart';
import 'package:apk_gizi/screens/auth/login_screen.dart';
import 'package:apk_gizi/screens/auth/register_screen.dart';
import 'package:apk_gizi/screens/home/home_screen.dart';
import 'package:apk_gizi/screens/biodata/biodata_screen.dart';
import 'package:apk_gizi/screens/kalkulator/kalkulator_screen.dart';
import 'package:apk_gizi/screens/hasil/hasil_screen.dart';
import 'package:apk_gizi/screens/jadwal/jadwal_screen.dart';
import 'package:apk_gizi/screens/history/history_screen.dart';
import 'package:apk_gizi/screens/profile/profile_screen.dart'; // Perbarui impor ini jika nama file berubah
import 'package:apk_gizi/data/models/user_data.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: AuthService.instance,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'biodata',
            builder: (context, state) => const BiodataScreen(),
          ),
          GoRoute(
            path: 'kalkulator',
            builder: (context, state) => const KalkulatorScreen(),
          ),
          GoRoute(
            path: 'hasil',
            name: 'hasil',
            builder: (context, state) {
              try {
                final userData = state.extra as UserData?;
                if (userData == null) {
                  debugPrint('AppRoutes: No UserData provided for HasilScreen');
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data tidak lengkap')),
                      );
                      context.go('/home/history');
                    }
                  });
                  return const HistoryScreen();
                }
                debugPrint('AppRoutes: Navigating to HasilScreen with userData=$userData');
                return HasilScreen(userData: userData);
              } catch (e) {
                debugPrint('Error navigating to HasilScreen: $e');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal membuka hasil: $e')),
                    );
                    context.go('/home/history');
                  }
                });
                return const HistoryScreen();
              }
            },
          ),
          GoRoute(
            path: 'jadwal',
            builder: (context, state) => const JadwalScreen(),
          ),
          GoRoute(
            path: 'history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ModernProfileScreen(), // Perbarui ke ModernProfileScreen
          ),
        ],
      ),
      // Tambahkan rute langsung untuk /hasil jika diperlukan
      GoRoute(
        path: '/hasil',
        name: 'hasil-direct',
        builder: (context, state) {
          try {
            final userData = state.extra as UserData?;
            if (userData == null) {
              debugPrint('AppRoutes: No UserData provided for HasilScreen (direct route)');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data tidak lengkap')),
                  );
                  context.go('/home/history');
                }
              });
              return const HistoryScreen();
            }
            debugPrint('AppRoutes: Navigating to HasilScreen with userData=$userData (direct route)');
            return HasilScreen(userData: userData);
          } catch (e) {
            debugPrint('Error navigating to HasilScreen (direct route): $e');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal membuka hasil: $e')),
                );
                context.go('/home/history');
              }
            });
            return const HistoryScreen();
          }
        },
      ),
    ],
    redirect: (context, state) {
      final loggedIn = AuthService.instance.token != null;
      final loggingIn = state.subloc == '/login' || state.subloc == '/register' || state.subloc == '/';
      debugPrint('AppRoutes: loggedIn=$loggedIn, loggingIn=$loggingIn, subloc=${state.subloc}');
      if (!loggedIn && !loggingIn) {
        debugPrint('AppRoutes: Redirecting to /login');
        return '/login';
      }
      if (loggedIn && loggingIn) {
        debugPrint('AppRoutes: Redirecting to /home');
        return '/home';
      }
      return null;
    },
  );
}