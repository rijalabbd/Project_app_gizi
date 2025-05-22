import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _waveController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;

  DateTime _centerDate = DateTime.now();
  late List<DateTime> _dates;
  DateTime _selectedDate = DateTime.now();

  static const int rangeDays = 60;
  static const double itemWidth = 77;

  final Map<String, IconData> _iconMap = {
    'wb_sunny_outlined': Icons.wb_sunny_outlined,
    'restaurant_outlined': Icons.restaurant_outlined,
    'nightlight_round_outlined': Icons.nightlight_round_outlined,
    'fastfood': Icons.fastfood,
    'local_cafe': Icons.local_cafe,
    'cake': Icons.cake,
    'emoji_food_beverage': Icons.emoji_food_beverage,
    'lunch_dining': Icons.lunch_dining,
  };

  final List<Map<String, dynamic>> _mealPresets = [
    {
      'label': 'Sarapan',
      'icon': 'wb_sunny_outlined',
      'time': '08:00',
      'color': const Color(0xFF4CAF50),
      'gradient': [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
      'completed': false,
      'category': 'Sehat',
    },
    {
      'label': 'Makan Siang',
      'icon': 'restaurant_outlined',
      'time': '12:00',
      'color': const Color(0xFF4CAF50),
      'gradient': [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
      'completed': false,
      'category': 'Biasa',
    },
    {
      'label': 'Makan Malam',
      'icon': 'nightlight_round_outlined',
      'time': '19:00',
      'color': const Color(0xFF4CAF50),
      'gradient': [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
      'completed': false,
      'category': 'Diet',
    },
  ];

  final List<String> _quotes = [
    "Makan teratur, hidup sehat! 🌟",
    "Nutrisi terbaik untuk hari terbaikmu! 💪",
    "Jadwal makan yang baik = Hidup yang lebih baik! ✨",
    "Kesehatan dimulai dari piring makanmu! 🍽️",
    "Tubuh sehat, pikiran cerdas! 🧠",
  ];

  late final String _todayQuote;
  int _streakCount = 0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _todayQuote = _quotes[Random().nextInt(_quotes.length)];
    _loadData();
    _dates = _generateDates(_centerDate);

    _scrollController = ScrollController();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _checkCompletedMeals();
    _calculateStreak();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _waveController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _saveData();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('mealPresets');
      if (jsonString != null) {
        final List<dynamic> loadedData = jsonDecode(jsonString);
        setState(() {
          _mealPresets.clear();
          _mealPresets.addAll(
            loadedData.map((item) {
              final Map<String, dynamic> meal = Map<String, dynamic>.from(item);
              if (meal['icon'] is String && _iconMap.containsKey(meal['icon'])) {
                meal['icon'] = meal['icon'];
              }
              if (meal['color'] is int) {
                meal['color'] = Color(meal['color']);
              }
              if (meal['gradient'] is List) {
                meal['gradient'] = (meal['gradient'] as List)
                    .map((color) => Color(color is int ? color : (color as Color).value))
                    .toList();
              }
              return meal;
            }).toList(),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saveablePresets = _mealPresets.map((meal) {
        final Map<String, dynamic> saveableMeal = Map<String, dynamic>.from(meal);
        saveableMeal['icon'] = saveableMeal['icon'] is String
            ? saveableMeal['icon']
            : _iconMap.entries
            .firstWhere((entry) => entry.value == saveableMeal['icon'],
            orElse: () => const MapEntry('fastfood', Icons.fastfood))
            .key;
        if (saveableMeal['color'] is Color) {
          saveableMeal['color'] = (saveableMeal['color'] as Color).value;
        }
        if (saveableMeal['gradient'] is List<Color>) {
          saveableMeal['gradient'] = (saveableMeal['gradient'] as List<Color>)
              .map((color) => color.value)
              .toList();
        }
        return saveableMeal;
      }).toList();
      final jsonString = jsonEncode(saveablePresets);
      await prefs.setString('mealPresets', jsonString);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: $e')),
        );
      }
    }
  }

  void _checkCompletedMeals() {
    final now = DateTime.now();
    if (_isSameDate(now, _selectedDate)) {
      setState(() {
        for (var meal in _mealPresets) {
          final parts = (meal['time'] as String).split(':');
          final mealTime = DateTime(
              now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
          meal['completed'] = mealTime.isBefore(now) || mealTime.isAtSameMomentAs(now);
        }
        _calculateStreak();
      });
    }
  }

  List<DateTime> _generateDates(DateTime center) {
    return List.generate(rangeDays * 2 + 1, (i) {
      return center.subtract(Duration(days: rangeDays)).add(Duration(days: i));
    });
  }

  void _updateCenterDate(DateTime newCenter) {
    setState(() {
      _centerDate = newCenter;
      _dates = _generateDates(_centerDate);
    });
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  double get _progress {
    final completed = _mealPresets.where((meal) => meal['completed'] == true).length;
    return completed / _mealPresets.length;
  }

  String get _progressText {
    final completed = _mealPresets.where((meal) => meal['completed'] == true).length;
    return '$completed dari ${_mealPresets.length} jadwal selesai';
  }

  void _calculateStreak() {
    final now = DateTime.now();
    final todayCompleted = _mealPresets.every((meal) => meal['completed'] == true);
    if (todayCompleted && _isSameDate(now, _selectedDate)) {
      setState(() {
        _streakCount++;
      });
    } else if (!_isSameDate(now, _selectedDate)) {
      setState(() {
        _streakCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false, // Menonaktifkan ikon kembali bawaan
                pinned: false,
                floating: false,
                expandedHeight: 240 + MediaQuery.of(context).padding.top,
                flexibleSpace: ClipPath(
                  clipper: _BottomCurveClipper(),
                  child: Stack(
                    children: [
                      Container(
                        height: 240 + MediaQuery.of(context).padding.top,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF4CAF50),
                              Color(0xFF66BB6A),
                              Color(0xFF81C784),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            ...List.generate(
                              6,
                                  (index) => AnimatedBuilder(
                                animation: _floatingController,
                                builder: (context, child) {
                                  return Positioned(
                                    top: 50 + (index * 30) + (_floatingController.value * 20),
                                    left: 20 +
                                        (index * 60) +
                                        (sin(_floatingController.value * 2 * pi + index) * 15),
                                    child: Container(
                                      width: 15 + (index % 3) * 5,
                                      height: 15 + (index % 3) * 5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: MediaQuery.of(context).padding.top + 16,
                              left: 16,
                              right: 16,
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        context.go('/home');
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Jadwal Makan',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Atur waktu makanmu dengan baik',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.restaurant_menu,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 40,
                              left: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Progress Hari Ini',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${(_progress * 100).toInt()}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: _progress,
                                        minHeight: 8,
                                        backgroundColor: Colors.white.withOpacity(0.3),
                                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _progressText,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: 60,
                          child: AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: _EnhancedWavePainter(
                                  _waveController.value,
                                  Colors.white.withOpacity(0.3),
                                ),
                                child: const SizedBox.expand(),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _todayQuote,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                  child: AnimationLimiter(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      controller: ScrollController(),
                      itemCount: _dates.length,
                      itemBuilder: (ctx, idx) {
                        final date = _dates[idx];
                        final isSelected = _isSameDate(date, _selectedDate);
                        final isToday = _isSameDate(date, DateTime.now());

                        return AnimationConfiguration.staggeredList(
                          position: idx,
                          duration: const Duration(milliseconds: 400),
                          child: SlideAnimation(
                            horizontalOffset: 50,
                            child: FadeInAnimation(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedDate = date);
                                  _checkCompletedMeals();

                                  final w = MediaQuery.of(context).size.width;
                                  final target = idx * itemWidth - (w / 2 - itemWidth / 2);
                                  _scrollController.animateTo(
                                    target.clamp(0, _dates.length * itemWidth - w),
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOut,
                                  );

                                  if (idx < 10 || idx > _dates.length - 10) {
                                    _updateCenterDate(date);
                                  }
                                },
                                child: Container(
                                  width: itemWidth,
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : (isToday ? Colors.orange.withOpacity(0.1) : Colors.transparent),
                                    borderRadius: BorderRadius.circular(16),
                                    border: isToday && !isSelected
                                        ? Border.all(color: Colors.orange, width: 2)
                                        : null,
                                    boxShadow: isSelected
                                        ? [
                                      BoxShadow(
                                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('EEE', 'id_ID').format(date),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : (isToday ? Colors.orange : Colors.black54),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        date.day.toString(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : (isToday ? Colors.orange : Colors.black87),
                                        ),
                                      ),
                                      if (isToday && !isSelected)
                                        Container(
                                          margin: const EdgeInsets.only(top: 2),
                                          width: 4,
                                          height: 4,
                                          decoration: const BoxDecoration(
                                            color: Colors.orange,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (_isSameDate(_selectedDate, DateTime.now()))
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_pulseController.value * 0.1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'HARI INI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
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
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      final meal = _mealPresets[i];
                      final isCompleted = meal['completed'] as bool;
                      final List<Color> gradientColors = (meal['gradient'] as List<dynamic>)
                          .map((color) => color is int ? Color(color) : color as Color)
                          .toList();

                      return AnimationConfiguration.staggeredList(
                        position: i,
                        duration: const Duration(milliseconds: 400),
                        child: SlideAnimation(
                          verticalOffset: 30,
                          child: FadeInAnimation(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isCompleted
                                      ? [
                                    Colors.green.withOpacity(0.1),
                                    Colors.green.withOpacity(0.05),
                                  ]
                                      : gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: (meal['color'] as Color).withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      meal['completed'] = !isCompleted;
                                      _saveData();
                                      _calculateStreak();
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Icon(
                                            _iconMap[meal['icon']] ?? Icons.fastfood,
                                            color: meal['color'] as Color,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                meal['label'] as String,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: isCompleted ? Colors.green : Colors.white,
                                                  decoration: isCompleted
                                                      ? TextDecoration.lineThrough
                                                      : null,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                isCompleted ? 'Selesai!' : 'Belum selesai',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isCompleted
                                                      ? Colors.green.withOpacity(0.8)
                                                      : Colors.white.withOpacity(0.8),
                                                ),
                                              ),
                                              Text(
                                                'Kategori: ${meal['category']}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white.withOpacity(0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            HapticFeedback.lightImpact();
                                            final parts = (meal['time'] as String).split(':');
                                            final picked = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay(
                                                hour: int.parse(parts[0]),
                                                minute: int.parse(parts[1]),
                                              ),
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context).copyWith(
                                                    timePickerTheme: TimePickerThemeData(
                                                      backgroundColor: Colors.white,
                                                      dialHandColor: meal['color'] as Color,
                                                      hourMinuteColor:
                                                      (meal['color'] as Color).withOpacity(0.1),
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                meal['time'] =
                                                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                                _saveData();
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.9),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 16,
                                                  color: meal['color'] as Color,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  meal['time'] as String,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: meal['color'] as Color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isCompleted
                                                ? Icons.check
                                                : Icons.radio_button_unchecked,
                                            color: isCompleted ? Colors.green : Colors.grey,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _mealPresets.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80), // Spacer untuk tombol sticky
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showAddScheduleSheet();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Tambah Jadwal Baru',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleSheet() {
    String newMeal = '';
    TimeOfDay? newTime;
    String selectedIconName = 'fastfood';
    Color selectedColor = const Color(0xFF4CAF50);
    String selectedCategory = 'Sehat';

    final availableIconNames = [
      'fastfood',
      'local_cafe',
      'cake',
      'emoji_food_beverage',
      'restaurant',
      'lunch_dining',
    ];

    final availableColors = [
      const Color(0xFF4CAF50),
      const Color(0xFF66BB6A),
      const Color(0xFF81C784),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
    ];

    final categories = ['Sehat', 'Diet', 'Biasa'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tambah Jadwal Makan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nama Jadwal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          _iconMap[selectedIconName] ?? Icons.fastfood,
                          color: selectedColor,
                        ),
                      ),
                      onChanged: (v) {
                        newMeal = v;
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pilih Kategori',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: categories.map((cat) {
                        final isSelected = cat == selectedCategory;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedCategory = cat;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? selectedColor.withOpacity(0.2) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: selectedColor, width: 2)
                                  : null,
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected ? selectedColor : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pilih Warna',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: availableColors.map((color) {
                        final isSelected = color == selectedColor;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.black, width: 3)
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pilih Ikon',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: availableIconNames.map((iconName) {
                        final isSelected = iconName == selectedIconName;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedIconName = iconName;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? selectedColor : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _iconMap[iconName] ?? Icons.fastfood,
                              color: isSelected ? Colors.white : Colors.grey[600],
                              size: 24,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: ctx,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    timePickerTheme: TimePickerThemeData(
                                      backgroundColor: Colors.white,
                                      dialHandColor: selectedColor,
                                      hourMinuteColor: selectedColor.withOpacity(0.1),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setModalState(() {
                                newTime = picked;
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, color: selectedColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    newTime != null
                                        ? '${newTime!.hour.toString().padLeft(2, '0')}:${newTime!.minute.toString().padLeft(2, '0')}'
                                        : 'Pilih Waktu',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: newTime != null ? Colors.black87 : Colors.grey[600],
                                    ),
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [selectedColor, selectedColor.withOpacity(0.8)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: selectedColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            if (newMeal.isNotEmpty && newTime != null) {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _mealPresets.add({
                                  'label': newMeal,
                                  'icon': selectedIconName,
                                  'time':
                                  '${newTime!.hour.toString().padLeft(2, '0')}:${newTime!.minute.toString().padLeft(2, '0')}',
                                  'color': selectedColor,
                                  'gradient': [
                                    selectedColor,
                                    selectedColor.withOpacity(0.8),
                                  ],
                                  'completed': false,
                                  'category': selectedCategory,
                                });
                                _saveData();
                              });
                              Navigator.pop(ctx);
                            } else {
                              HapticFeedback.vibrate();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mohon lengkapi semua field'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Simpan Jadwal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height - 20,
      size.width * 0.5,
      size.height - 30,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 40,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _EnhancedWavePainter extends CustomPainter {
  final double animation;
  final Color color;

  const _EnhancedWavePainter(this.animation, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);
    for (double x = 0; x <= size.width; x++) {
      final y1 = sin((x / size.width * 4 * pi) + animation * 2 * pi) * 8;
      final y2 = cos((x / size.width * 2 * pi) + animation * pi) * 4;
      path1.lineTo(x, size.height * 0.7 + y1 + y2);
    }
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint);

    final paint2 = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.8);
    for (double x = 0; x <= size.width; x++) {
      final y = sin((x / size.width * 3 * pi) - animation * 1.5 * pi) * 6;
      path2.lineTo(x, size.height * 0.8 + y);
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _EnhancedWavePainter oldDelegate) =>
      oldDelegate.animation != animation;
}