import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:apk_gizi/screens/biodata/biodata_screen.dart';
import 'package:apk_gizi/screens/jadwal/jadwal_screen.dart';
import 'package:apk_gizi/screens/history/history_screen.dart';
import 'package:apk_gizi/screens/profile/profile_screen.dart';
import '../../core/widgets/custom_bottom_nav_bar.dart';
import 'package:apk_gizi/services/api/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String baseUrl = 'http://10.0.2.2:8000';
  int _currentIndex = 0;
  String? _userName;
  String _todayTip = '';
  int _jadwalCount = 0;
  bool _loadingProfile = true;

  final List<String> _tips = [
    "Catat setiap perhitungan BMI-mu",
    "Perhatikan asupan harian karbohidrat",
    "Pastikan protein cukup setiap hari",
  ];

  @override
  void initState() {
    super.initState();
    _todayTip = _tips[Random().nextInt(_tips.length)];
    _checkAuthAndLoad();
  }

  Future<void> _checkAuthAndLoad() async {
    // 1. Periksa token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      if (!mounted) return;
      context.go('/login');
      return;
    }

    // 2. Load profile & jadwal count bersamaan
    await Future.wait([_loadProfile(token), _loadJadwalCount(token)]);
  }

  Future<void> _loadProfile(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        _userName = data['name'];
        _loadingProfile = false;
      });
    } else {
      // token invalid/expired
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      if (!mounted) return;
      context.go('/login');
    }
  }

  Future<void> _loadJadwalCount(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/jadwal-makan'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      setState(() => _jadwalCount = list.length);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    // panggil API logout
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    await prefs.remove('auth_token');
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),
      const BiodataScreen(),
      const JadwalScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
      ),
    );
  }

  Widget _buildDashboard() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox(),
        title: _loadingProfile
            ? const Text('...') 
            : Text(
                'Hallo, $_userName!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _checkAuthAndLoad(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Selamat Datang Di NutriTracker',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _todayTip,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AnimationLimiter(
                  child: Column(
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 500),
                      childAnimationBuilder: (widget) =>
                          SlideAnimation(verticalOffset: 50.0, child: FadeInAnimation(child: widget)),
                      children: [
                        AnimatedMenuItem(
                          title: 'Kalkulator Gizi',
                          icon: FontAwesomeIcons.calculator,
                          bgColor: const Color(0xFFD8B4FE),
                          onTap: () => setState(() => _currentIndex = 1),
                        ),
                        const SizedBox(height: 16),
                        AnimatedMenuItem(
                          title: 'Jadwal ($_jadwalCount)',
                          icon: FontAwesomeIcons.calendar,
                          bgColor: const Color(0xFFFFCC80),
                          onTap: () => setState(() => _currentIndex = 2),
                        ),
                        const SizedBox(height: 16),
                        AnimatedMenuItem(
                          title: 'Riwayat',
                          icon: FontAwesomeIcons.rotateLeft,
                          bgColor: const Color(0xFF80CBC4),
                          onTap: () => setState(() => _currentIndex = 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedMenuItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color bgColor;
  final VoidCallback onTap;

  const AnimatedMenuItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<AnimatedMenuItem> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) => setState(() => _scale = 0.95);
  void _onTapUp(TapUpDetails _) {
    setState(() => _scale = 1.0);
    widget.onTap();
  }
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(widget.icon, size: 36, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
