import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  DateTime _centerDate = DateTime.now();
  late List<DateTime> _dates;
  DateTime _selectedDate = DateTime.now();

  static const int rangeDays = 60;
  static const double itemWidth = 77;

  final List<Map<String, dynamic>> _mealPresets = [
    {'label': 'Sarapan', 'icon': Icons.free_breakfast, 'time': '08:00'},
    {'label': 'Makan Siang', 'icon': Icons.restaurant, 'time': '12:00'},
    {'label': 'Makan Malam', 'icon': Icons.bedtime, 'time': '19:00'},
  ];

  final List<String> _quotes = [
    "",

  ];
  late final String _todayQuote;

  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _todayQuote = _quotes[Random().nextInt(_quotes.length)];
    
    // Generate dates around center date
    _dates = _generateDates(_centerDate);
    
    // Initialize scroll controller positioning at today
    _scrollController = ScrollController(
      initialScrollOffset: rangeDays * itemWidth,
    );
    
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _waveController.dispose();
    super.dispose();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(rangeDays * itemWidth);
    });
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  double get _progress {
    final now = DateTime.now();
    if (!_isSameDate(now, _selectedDate)) return 0.0;
    final done = _mealPresets.where((meal) {
      final parts = (meal['time'] as String).split(':');
      final dt = DateTime(now.year, now.month, now.day,
          int.parse(parts[0]), int.parse(parts[1]));
      return dt.isBefore(now);
    }).length;
    return done / _mealPresets.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // HEADER
          ClipPath(
            clipper: _BottomCurveClipper(),
            child: Stack(
              children: [
                Container(
                  height: 200 + MediaQuery.of(context).padding.top,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFA726), Color(0xFFFFB74D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Stack(
                    children: [
                      Center(
                        child: Opacity(
                          opacity: 0.08,
                          child: Text(
                            _todayQuote.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 100,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.calendar_today,
                                color: Colors.white),
                            const SizedBox(width: 8),
                            const Text(
                              'Jadwal Makan',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
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
                    height: 40,
                    child: AnimatedBuilder(
                      animation: _waveController,
                      builder: (_, __) => CustomPaint(
                        painter: _WavePainter(
                          _waveController.value,
                          Colors.white.withOpacity(0.3),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // QUOTE & PROGRESS BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Text(_todayQuote,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFD8B4FE)),
                ),
              ],
            ),
          ),

          // DATE PICKER (ANIMASI)
          SizedBox(
            height: 90,
            child: AnimationLimiter(
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _dates.length,
                itemBuilder: (ctx, idx) {
                  final date = _dates[idx];
                  final isSelected = _isSameDate(date, _selectedDate);
                  
                  return AnimationConfiguration.staggeredList(
                    position: idx,
                    duration: const Duration(milliseconds: 300),
                    child: SlideAnimation(
                      horizontalOffset: 50,
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedDate = date);
                            
                            // Center selected date in view
                            final w = MediaQuery.of(context).size.width;
                            final target = idx * itemWidth - (w / 2 - itemWidth / 2);
                            _scrollController.animateTo(
                              target.clamp(
                                _scrollController.position.minScrollExtent,
                                _scrollController.position.maxScrollExtent,
                              ),
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                            );
                            
                            // Update center date when near edge
                            if (idx < 10 || idx > _dates.length - 10) {
                              _updateCenterDate(date);
                            }
                          },
                          child: Container(
                            width: 65,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFD8B4FE)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('EEE', 'id_ID').format(date),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isSelected ? Colors.white : Colors.black87,
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

          // FULL DATE LABEL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                    .format(_selectedDate),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // SCHEDULE LIST
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimationLimiter(
                child: ListView.builder(
                  itemCount: _mealPresets.length,
                  itemBuilder: (context, i) {
                    final meal = _mealPresets[i];
                    return AnimationConfiguration.staggeredList(
                      position: i,
                      duration: const Duration(milliseconds: 300),
                      child: SlideAnimation(
                        verticalOffset: 20,
                        child: FadeInAnimation(
                          child: Column(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6),
                                elevation: 1,
                                child: ListTile(
                                  leading: Icon(meal['icon'] as IconData,
                                      color: Colors.deepOrange),
                                  title: Text(meal['label'] as String,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  trailing: GestureDetector(
                                    onTap: () async {
                                      final parts = (meal['time'] as String).split(':');
                                      final picked = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay(
                                          hour: int.parse(parts[0]),
                                          minute: int.parse(parts[1]),
                                        ),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          meal['time'] = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                        });
                                      }
                                    },
                                    child: Text(meal['time'] as String),
                                  ),
                                ),
                              ),
                              if (i < _mealPresets.length - 1)
                                const Divider(
                                    height: 1, indent: 16, endIndent: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // BUTTON ADD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showAddScheduleSheet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD8B4FE),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Tambah Jadwal',
                    style: TextStyle(color: Colors.black87)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        String newMeal = '';
        TimeOfDay? newTime;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nama Jadwal'),
                onChanged: (v) => newMeal = v,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  newTime = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay.now(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD8B4FE),
                ),
                child: const Text('Pilih Waktu'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (newMeal.isNotEmpty && newTime != null) {
                    setState(() {
                      _mealPresets.add({
                        'label': newMeal,
                        'icon': Icons.fastfood,
                        'time': '${newTime!.hour.toString().padLeft(2, '0')}:${newTime!.minute.toString().padLeft(2, '0')}',
                      });
                    });
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simpan Jadwal'),
              ),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom),
            ]
          ),
        );
      },
    );
  }
}

// Clipper lengkung bawah header
class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.moveTo(0, 0);
    p.lineTo(0, size.height - 40);
    p.quadraticBezierTo(
        size.width / 2, size.height + 40, size.width, size.height - 40);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

// Painter gelombang bawah
class _WavePainter extends CustomPainter {
  final double animation;
  final Color color;
  const _WavePainter(this.animation, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path();
    final yOffset = size.height / 2;
    p.moveTo(0, yOffset);
    for (double x = 0; x <= size.width; x++) {
      final y = sin((x / size.width * 2 * pi) + animation * 2 * pi);
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