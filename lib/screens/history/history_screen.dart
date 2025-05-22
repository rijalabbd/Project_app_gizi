import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:apk_gizi/data/models/history_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  final List<String> _tips = [
    "HEALTHY LIVING",
    "BALANCED DIET",
    "NUTRITION FIRST",
    "WELLNESS JOURNEY",
    "MINDFUL EATING"
  ];

  late AnimationController _waveController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  List<HistoryEntry> _history = [];

  final Color _primaryColor = const Color(0xFF00BCD4);
  final Color _secondaryColor = const Color(0xFF26C6DA);
  final Color _accentColor = const Color(0xFF00ACC1);
  final Color _surfaceColor = const Color(0xFFF8FDFF);

  @override
  void initState() {
    super.initState();
    _loadHistory();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> historyData = prefs.getStringList('history') ?? [];
      setState(() {
        _history = historyData
            .map((jsonString) {
          try {
            final entry = HistoryEntry.fromJson(jsonDecode(jsonString));
            return entry;
          } catch (e) {
            debugPrint('Error parsing history entry: $e, JSON: $jsonString');
            return null;
          }
        })
            .where((entry) => entry != null)
            .cast<HistoryEntry>()
            .toList();
      });
    } catch (e) {
      debugPrint('Error loading history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat histori: $e')),
        );
      }
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> historyData =
      _history.map((entry) => jsonEncode(entry.toJson())).toList().cast<String>();
      await prefs.setStringList('history', historyData);
    } catch (e) {
      debugPrint('Error saving history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan histori: $e')),
        );
      }
    }
  }

  void addHistoryEntry(HistoryEntry entry) {
    setState(() {
      _history.insert(0, entry);
    });
    _saveHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceColor,
      body: Column(
        children: [
          _buildModernHeader(),
          _buildStatsSummary(),
          Expanded(child: _buildHistoryList()),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      height: 280 + MediaQuery.of(context).padding.top,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor.withValues(alpha: 1.0), _secondaryColor.withValues(alpha: 1.0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ModernPatternPainter(_waveController.value),
                size: Size.infinite,
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _fadeController,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Riwayat Perhitungan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Pantau progress nutrisi Anda',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.insights,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _slideController,
                      curve: Curves.easeOutCubic,
                    )),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.timeline,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Perjalanan Sehat Anda',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Setiap langkah menuju hidup lebih sehat',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    final totalCalories = _history.fold<int>(0, (sum, entry) => sum + entry.calories);
    final avgCalories = _history.isNotEmpty ? (totalCalories / _history.length).round() : 0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Entri',
              '${_history.length}',
              Icons.assessment,
              _primaryColor,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildStatItem(
              'Rata-rata',
              '$avgCalories kkal',
              Icons.trending_up,
              _accentColor,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildStatItem(
              'Total',
              '$totalCalories kkal',
              Icons.local_fire_department,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada histori perhitungan.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final entry = _history[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 100)),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildHistoryCard(entry, index),
        );
      },
    );
  }

  Widget _buildHistoryCard(HistoryEntry entry, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(20),
          backgroundColor: Colors.transparent,
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor.withValues(alpha: 1.0), _secondaryColor.withValues(alpha: 1.0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            _formatDate(entry.date),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.local_fire_department,
                      color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.calories} kkal',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildNutrientIndicators(entry),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailedNutrients(entry),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Share functionality
                          },
                          icon: Icon(Icons.share, size: 16),
                          label: const Text('Bagikan'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primaryColor,
                            side: BorderSide(color: _primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fitur analisis belum tersedia')),
                            );
                          },
                          icon: const Icon(Icons.analytics, size: 16),
                          label: const Text('Analisis'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor.withValues(alpha: 0.5),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientIndicators(HistoryEntry entry) {
    return Row(
      children: [
        _buildMiniIndicator('C', entry.carb, Colors.blue),
        const SizedBox(width: 8),
        _buildMiniIndicator('P', entry.protein, Colors.green),
        const SizedBox(width: 8),
        _buildMiniIndicator('F', entry.fat, Colors.orange),
      ],
    );
  }

  Widget _buildMiniIndicator(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$label: ${value}g',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedNutrients(HistoryEntry entry) {
    return Column(
      children: [
        _buildNutrientRow('Karbohidrat', entry.carb, 'g', Colors.blue, 0.7),
        const SizedBox(height: 12),
        _buildNutrientRow('Protein', entry.protein, 'g', Colors.green, 0.6),
        const SizedBox(height: 12),
        _buildNutrientRow('Lemak', entry.fat, 'g', Colors.orange, 0.5),
      ],
    );
  }

  Widget _buildNutrientRow(String label, int value, String unit, Color color, double progress) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toInt()}% dari target',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Text(
          '$value $unit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _ModernPatternPainter extends CustomPainter {
  final double animation;

  _ModernPatternPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final offset = Offset(
        (i * size.width / 5) + (sin(animation * 2 * pi + i) * 30),
        (i * size.height / 8) + (cos(animation * 2 * pi + i) * 20),
      );
      canvas.drawCircle(offset, 20 + (i * 5), paint);
    }

    final path = Path();
    for (double x = 0; x <= size.width; x += 2) {
      final y1 = size.height * 0.3 +
          sin((x / size.width * 2 * pi) + (animation * 2 * pi)) * 15;

      if (x == 0) {
        path.moveTo(x, y1);
      } else {
        path.lineTo(x, y1);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.05)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _ModernPatternPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}