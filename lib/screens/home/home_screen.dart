import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apk_gizi/services/auth_service.dart'; // Impor AuthService
import '../../core/widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const _baseUrl = 'http://10.0.2.2:8000/api';

  String? _userName;
  String _todayTip = '';
  int _jadwalCount = 0;
  bool _loadingProfile = true;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _rotateController;
  late AnimationController _floatingIconsController;
  late AnimationController _avatarPulseController;
  late AnimationController _textFadeController;

  // Animations for floating icons
  late List<Animation<double>> _floatingIconsAnimations;
  final List<Offset> _floatingIconsOffsets = [];
  final List<IconData> _floatingIcons = [
    FontAwesomeIcons.apple,
    FontAwesomeIcons.carrot,
    FontAwesomeIcons.bowlRice,
    FontAwesomeIcons.breadSlice,
    FontAwesomeIcons.egg,
  ];

  final _tips = [
    "Catat setiap perhitungan BMI-mu untuk melihat progres",
    "Perhatikan asupan harian karbohidrat untuk energi optimal",
    "Pastikan protein cukup setiap hari untuk kesehatan otot",
    "Air putih minimal 8 gelas sehari untuk metabolisme yang baik",
    "Konsumsi cukup serat untuk pencernaan yang sehat",
  ];

  final List<Color> _gradientColors = [
    const Color(0xFF6A60F9),
    const Color(0xFF8A6AFE),
    const Color(0xFF4A90E2),
  ];

  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _todayTip = _tips[Random().nextInt(_tips.length)];
    _checkAuthAndLoad();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _floatingIconsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _avatarPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _setupFloatingIconsAnimations();
  }

  void _setupFloatingIconsAnimations() {
    _floatingIconsAnimations = [];
    _floatingIconsOffsets.clear();

    final random = Random();
    for (int i = 0; i < _floatingIcons.length; i++) {
      _floatingIconsOffsets.add(Offset(
        random.nextDouble() * 300 - 150,
        random.nextDouble() * 200 - 100,
      ));

      final begin = random.nextDouble() * 0.3;
      final end = begin + 1.0;

      _floatingIconsAnimations.add(
        Tween<double>(begin: begin, end: end).animate(
          CurvedAnimation(
            parent: _floatingIconsController,
            curve: Interval(
              begin,
              end > 1.0 ? 1.0 : end,
              curve: Curves.easeInOutSine,
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _rotateController.dispose();
    _floatingIconsController.dispose();
    _avatarPulseController.dispose();
    _textFadeController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      await AuthService.instance.clear();
      return;
    }
    await Future.wait([
      _loadProfile(token),
      _loadJadwalCount(token),
    ]);
  }

  Future<void> _loadProfile(String token) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _userName = data['name'] as String?;
        _loadingProfile = false;
      });
    } else {
      await AuthService.instance.clear();
    }
  }

  Future<void> _loadJadwalCount(String token) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/jadwal-makan'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      if (!mounted) return;
      setState(() => _jadwalCount = list.length);
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    await AuthService.instance.clear();

    http.post(Uri.parse('$_baseUrl/logout'),
        headers: {'Accept': 'application/json'}).then((res) {
      debugPrint('▶️ Logout status: ${res.statusCode}');
      debugPrint('▶️ Logout body: ${res.body}');
    }).catchError((e) {
      debugPrint('▶️ Logout error: $e');
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logout berhasil'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Hero(
      tag: 'user_avatar',
      child: AnimatedBuilder(
        animation: _avatarPulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.95 + (0.05 * _avatarPulseController.value),
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8 + (4 * _avatarPulseController.value),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _rotateController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -_rotateController.value * pi,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: SweepGradient(
                                colors: [
                                  _gradientColors[0],
                                  _gradientColors[1].withValues(alpha: 0.5),
                                  _gradientColors[2],
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 70,
                      width: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Text(
                              _loadingProfile
                                  ? '...'
                                  : (_userName?.isNotEmpty == true
                                      ? _userName![0].toUpperCase()
                                      : 'U'),
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _gradientColors[0],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            setState(() {
              _scrollOffset = scrollInfo.metrics.pixels;
            });
            return false;
          },
          child: RefreshIndicator(
            onRefresh: _checkAuthAndLoad,
            color: _gradientColors[0],
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 260.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size(MediaQuery.of(context).size.width, 260),
                              painter: WavePainter(
                                animation: _waveController,
                                gradientColors: _gradientColors,
                                scrollOffset: _scrollOffset,
                              ),
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: _rotateController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotateController.value * 2 * pi,
                              child: Center(
                                child: Container(
                                  width: 320,
                                  height: 320,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        _gradientColors[0].withValues(alpha: 0.0),
                                        _gradientColors[1].withValues(alpha: 0.3),
                                        _gradientColors[2].withValues(alpha: 0.0),
                                      ],
                                      stops: const [0.7, 0.8, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: _floatingIconsController,
                          builder: (context, child) {
                            return Stack(
                              children: List.generate(_floatingIcons.length, (index) {
                                final animation = _floatingIconsAnimations[index];
                                final offset = _floatingIconsOffsets[index];

                                final dx = sin(animation.value * pi * 2) * 40 +
                                    cos(animation.value * pi) * 20 +
                                    offset.dx;
                                final dy = cos(animation.value * pi * 2) * 30 +
                                    sin(animation.value * pi) * 15 +
                                    offset.dy;

                                return Positioned(
                                  left: MediaQuery.of(context).size.width / 2 + dx,
                                  top: 130 + dy,
                                  child: GestureDetector(
                                    onTap: () {
                                      _floatingIconsController.stop();
                                      Future.delayed(const Duration(milliseconds: 300), () {
                                        _floatingIconsController.repeat();
                                      });
                                    },
                                    child: Opacity(
                                      opacity: 0.3 + (animation.value * 0.4),
                                      child: Transform.rotate(
                                        angle: animation.value * pi,
                                        child: FaIcon(
                                          _floatingIcons[index],
                                          color: Colors.white.withValues(alpha: 0.7),
                                          size: 16 + (animation.value * 8),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                        SafeArea(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildUserAvatar(),
                                const SizedBox(height: 12),
                                AnimatedBuilder(
                                  animation: _textFadeController,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _textFadeController.value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - _textFadeController.value)),
                                        child: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 500),
                                          child: _loadingProfile
                                              ? const Text(
                                                  '...',
                                                  key: ValueKey('loading'),
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Text(
                                                  'Hallo, ${_userName ?? 'User'}!',
                                                  key: ValueKey('greeting'),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 6),
                                AnimatedBuilder(
                                  animation: _textFadeController,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _textFadeController.value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - _textFadeController.value)),
                                        child: ShaderMask(
                                          shaderCallback: (bounds) => LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.white.withValues(alpha: 0.8),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ).createShader(bounds),
                                          child: Text(
                                            'Selamat Datang Di NutriTracker',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      tooltip: 'Logout',
                      onPressed: _logout,
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 0.9 + (0.1 * _pulseController.value),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _gradientColors[0].withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ShaderMask(
                                        shaderCallback: (bounds) {
                                          return LinearGradient(
                                            colors: _gradientColors,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ).createShader(bounds);
                                        },
                                        child: const Icon(
                                          Icons.lightbulb_outline,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                          colors: _gradientColors,
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        'Tip Hari Ini',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _todayTip,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final items = [
                          MenuItemData(
                            title: 'Kalkulator Gizi',
                            subtitle: 'Hitung kebutuhan nutrisimu',
                            icon: FontAwesomeIcons.calculator,
                            bgColor: const Color(0xFF9980FA),
                            route: '/home/biodata',
                          ),
                          MenuItemData(
                            title: 'Jadwal Makan',
                            subtitle: 'Kamu memiliki $_jadwalCount jadwal',
                            icon: FontAwesomeIcons.calendarCheck,
                            bgColor: const Color(0xFFFF9F43),
                            route: '/home/jadwal',
                            badgeCount: _jadwalCount,
                          ),
                          MenuItemData(
                            title: 'Riwayat',
                            subtitle: 'Lihat perkembangan nutrisimu',
                            icon: FontAwesomeIcons.clockRotateLeft,
                            bgColor: const Color(0xFF1DD1A1),
                            route: '/home/history',
                          ),
                        ];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EnhancedMenuItem(
                            data: items[index],
                            pulseController: _pulseController,
                            onTap: () => context.go(items[index].route),
                          ),
                        );
                      },
                      childCount: 3,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (idx) {
          switch (idx) {
            case 0:
              break;
            case 1:
              context.go('/home/biodata');
              break;
            case 2:
              context.go('/home/jadwal');
              break;
            case 3:
              context.go('/home/history');
              break;
            case 4:
              context.go('/home/profile');
              break;
          }
        },
      ),
    );
  }
}

class MenuItemData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final String route;
  final int badgeCount;

  MenuItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgColor,
    required this.route,
    this.badgeCount = 0,
  });
}

class EnhancedMenuItem extends StatelessWidget {
  final MenuItemData data;
  final VoidCallback onTap;
  final AnimationController pulseController;

  const EnhancedMenuItem({
    super.key,
    required this.data,
    required this.onTap,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: data.bgColor.withValues(alpha: 0.1),
        highlightColor: data.bgColor.withValues(alpha: 0.05),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: data.bgColor.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: data.bgColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FaIcon(
                        data.icon,
                        size: 24,
                        color: data.bgColor,
                      ),
                    ),
                    if (data.badgeCount > 0)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: AnimatedBuilder(
                          animation: pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.9 + (0.1 * pulseController.value),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              data.badgeCount.toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> gradientColors;
  final double scrollOffset;

  WavePainter({
    required this.animation,
    required this.gradientColors,
    this.scrollOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.shader = LinearGradient(
      colors: gradientColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      tileMode: TileMode.mirror,
      transform: GradientRotation(animation.value * pi),
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final backgroundPath = Path();
    backgroundPath.addRRect(RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bottomLeft: const Radius.circular(30),
      bottomRight: const Radius.circular(30),
    ));
    canvas.drawPath(backgroundPath, paint);

    drawWave(canvas, size, animation.value + (scrollOffset * 0.001), 0.5);
    drawWave(canvas, size, animation.value - 0.5 + (scrollOffset * 0.0015), 0.3);
  }

  void drawWave(Canvas canvas, Size size, double animationValue, double opacity) {
    if (animationValue < 0) animationValue += 1;

    final double waveHeight = 20.0;
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.8);

    for (double i = 0; i < size.width; i++) {
      final y = size.height * 0.8 +
          sin((i / size.width * 4 * pi) + (animationValue * 2 * pi)) * waveHeight +
          sin((i / size.width * 2 * pi) + (animationValue * 2 * pi)) * waveHeight * 0.5;
      path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}