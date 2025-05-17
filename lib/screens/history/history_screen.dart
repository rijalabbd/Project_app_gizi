// lib/screens/history/history_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:apk_gizi/data/models/history_entry.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  // contoh tip untuk watermark
  final List<String> _tips = [
    "",

  ];
  late String _todayTip;

  // sample 3 histori statis
  final List<HistoryEntry> _history = [
    HistoryEntry(
      date: DateTime(2025, 5, 3),
      calories: 1800,
      carb: 220,
      protein: 75,
      fat: 60,
    ),
    HistoryEntry(
      date: DateTime(2025, 5, 2),
      calories: 2000,
      carb: 250,
      protein: 80,
      fat: 70,
    ),
    HistoryEntry(
      date: DateTime(2025, 5, 1),
      calories: 1700,
      carb: 200,
      protein: 65,
      fat: 55,
    ),
  ];

  // gradient toska
  final Color _startColor = const Color(0xFF009688);
  final Color _endColor = const Color(0xFF4DB6AC);

  // wave animation
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _todayTip = _tips[Random().nextInt(_tips.length)];
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // kita sembunyikan appBar bawaan agar header custom penuh
      body: Column(
        children: [
          // ===== HEADER CUSTOM =====
          ClipPath(
            clipper: _BottomCurveClipper(),
            child: Stack(
              children: [
                Container(
                  height: 220 + MediaQuery.of(context).padding.top,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_startColor, _endColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Stack(
                    children: [
                      // watermark tip samar
                      Center(
                        child: Opacity(
                          opacity: 0.06,
                          child: Text(
                            _todayTip.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 90,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // tombol back + judul
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_back, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.history, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text(
                              'Riwayat Perhitungan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // gelombang animasi di tepian bawah
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 50,
                    child: AnimatedBuilder(
                      animation: _waveController,
                      builder: (_, __) => CustomPaint(
                        painter: _WavePainter(
                          _waveController.value,
                          Colors.white.withOpacity(0.6),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== LIST HISTORI =====
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (ctx, i) {
                final e = _history[i];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: Colors.white,
                    leading: Icon(Icons.history, color: _endColor),
                    title: Text(
                      e.date.toLocal().toIso8601String().split('T').first,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${e.calories} kkal',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    childrenPadding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    children: [
                      _detailRow('Karbohidrat', e.carb, 'g'),
                      _detailRow('Protein', e.protein, 'g'),
                      _detailRow('Lemak', e.fat, 'g'),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: Icon(Icons.analytics, color: _endColor),
                          label: Text(
                            'Detail Statistik',
                            style: TextStyle(color: _endColor),
                          ),
                          onPressed: () {
                            // TODO: navigasi ke halaman chart detail
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, int value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text('$value $unit', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Clipper untuk lengkungan ke atas di tepian bawah header
class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 30,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

/// Painter sederhana menggambar satu gelombang sine
class _WavePainter extends CustomPainter {
  final double animation;
  final Color color;
  _WavePainter(this.animation, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path();
    final yOffset = size.height / 2;
    p.moveTo(0, yOffset);
    for (double x = 0; x <= size.width; x++) {
      final y = sin((x / size.width * 2 * pi) + (animation * 2 * pi));
      p.lineTo(x, yOffset + y * 10);
    }
    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height);
    p.close();
    canvas.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) =>
      old.animation != animation;
}
