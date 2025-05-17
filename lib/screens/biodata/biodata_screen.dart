import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../hasil/hasil_screen.dart';

class BiodataScreen extends StatefulWidget {
  const BiodataScreen({super.key});
  @override
  State<BiodataScreen> createState() => _BiodataScreenState();
}

class _BiodataScreenState extends State<BiodataScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;

  // Step 0: nama individu
  String _name = '';

  // Step 1: gender
  bool _isMale = true;

  // Step 2: data
  int _age = 25;
  double _weight = 70;
  double _height = 170;

  // Step 3: aktivitas
  final List<String> _activityLevels = ['Rendah', 'Sedang', 'Tinggi'];
  String _selectedActivity = 'Rendah';

  // Step 4: tujuan
  final List<String> _goals = [
    'Menurunkan Berat Badan',
    'Menjaga Berat Badan',
    'Meningkatkan Berat Badan'
  ];
  String _selectedGoal = 'Menjaga Berat Badan';

  // Kalkulasi & loading
  double? _bmi;
  bool _isLoading = false;

  // Tip harian (watermark)
  final List<String> _tips = [
    "",
    
  ];
  late String _todayTip;

  // Theme colors
  final Color _startColor = const Color(0xFF7E57C2);
  final Color _endColor = const Color(0xFFF48FB1);

  // Wave animation
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

  void _next() {
    if (_currentStep == 0 && _name.trim().isEmpty) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Masukkan nama')));
      return;
    }
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      _calculateAndGo();
    }
  }

  void _back() {
    if (_currentStep > 0) setState(() => _currentStep--);
    else
      Navigator.pop(context);
  }

  void _calculateAndGo() {
    setState(() {
      _isLoading = true;
      _bmi = null;
    });
    Timer(const Duration(milliseconds: 800), () {
      final h = _height / 100;
      final val = _weight / (h * h);
      setState(() {
        _bmi = double.parse(val.toStringAsFixed(1));
        _isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HasilScreen(
            bmi: _bmi!,
            statusBmi: _bmiStatus,
            gender: _isMale ? 'Laki-laki' : 'Perempuan',
            age: _age,
            weight: _weight,
            height: _height,
            activity: _selectedActivity,
            goal: _selectedGoal,
          ),
        ),
      );
    });
  }

  String get _bmiStatus {
    if (_bmi == null) return '';
    if (_bmi! < 18.5) return 'Kekurangan Berat Badan';
    if (_bmi! < 25) return 'Normal';
    if (_bmi! < 30) return 'Kelebihan Berat Badan';
    return 'Obesitas';
  }

  @override
  Widget build(BuildContext context) {
    const totalSteps = 6;
    final progress = (_currentStep + 1) / totalSteps;

    return Scaffold(
      body: Column(
        children: [
          // Header dengan lengkung bawah, gradient, watermark & wave
          ClipPath(
            clipper: BottomCurveClipper(),
            child: Stack(
              children: [
                Container(
                  height: 200 + MediaQuery.of(context).padding.top,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_startColor, _endColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Stack(
                    children: [
                      // Watermark teks tip
                      Center(
                        child: Opacity(
                          opacity: 0.08,
                          child: Text(
                            _todayTip.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 100,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Tombol kembali + judul
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.calculate, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text(
                              'Kalkulator Gizi',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Wave di tepian bawah
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
                            _waveController.value, _endColor.withOpacity(0.6)),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Progress icons + bar + %
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stepIcon(Icons.person, 1),
                    _stepIcon(Icons.male, 2),
                    _stepIcon(Icons.data_usage, 3),
                    _stepIcon(Icons.fitness_center, 4),
                    _stepIcon(Icons.flag, 5),
                    _stepIcon(Icons.check_circle, 6),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 400),
                        builder: (context, val, _) => LinearProgressIndicator(
                          value: val,
                          backgroundColor: _endColor.withOpacity(0.3),
                          color: _endColor,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress * 100),
                      duration: const Duration(milliseconds: 400),
                      builder: (context, val, _) => Text(
                        '${val.round()}%',
                        style: TextStyle(color: _endColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stepper
          Expanded(
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: _next,
              onStepCancel: _back,
              controlsBuilder: (_, details) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    if (_currentStep > 0) ...[
                      OutlinedButton.icon(
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.purple),
                        label: const Text('Kembali',
                            style: TextStyle(color: Colors.purple)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.purple),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                        ),
                        onPressed: details.onStepCancel,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          _currentStep == totalSteps - 1
                              ? Icons.check
                              : Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        label: Text(
                          _currentStep == totalSteps - 1 ? 'Hitung' : 'Lanjut',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _endColor,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: details.onStepContinue,
                      ),
                    ),
                  ],
                ),
              ),
              steps: [
                Step(
                  title: const Text('Nama'),
                  isActive: _currentStep >= 0,
                  content: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Masukkan Nama',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    onChanged: (v) => _name = v,
                  ),
                ),
                Step(
                  title: const Text('Gender'),
                  isActive: _currentStep >= 1,
                  content: ToggleButtons(
                    borderRadius: BorderRadius.circular(8),
                    fillColor: _isMale ? Colors.blue : Colors.pink,
                    selectedColor: Colors.white,
                    children: const [
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text('Laki-laki')),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text('Perempuan')),
                    ],
                    isSelected: [_isMale, !_isMale],
                    onPressed: (i) => setState(() => _isMale = i == 0),
                  ),
                ),
                Step(
                  title: const Text('Data'),
                  isActive: _currentStep >= 2,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Umur (tahun)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Slider(
                        value: _age.toDouble(),
                        min: 1,
                        max: 120,
                        divisions: 119,
                        activeColor: _endColor,
                        label: '$_age',
                        onChanged: (v) => setState(() => _age = v.round()),
                      ),
                      Text('$_age tahun'),
                      const SizedBox(height: 12),
                      const Text('Berat (kg)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Slider(
                        value: _weight,
                        min: 20,
                        max: 200,
                        divisions: 180,
                        activeColor: _endColor,
                        label: '${_weight.round()}',
                        onChanged: (v) => setState(() => _weight = v),
                      ),
                      Text('${_weight.round()} kg'),
                      const SizedBox(height: 12),
                      const Text('Tinggi (cm)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Slider(
                        value: _height,
                        min: 100,
                        max: 220,
                        divisions: 120,
                        activeColor: _endColor,
                        label: '${_height.round()}',
                        onChanged: (v) => setState(() => _height = v),
                      ),
                      Text('${_height.round()} cm'),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Aktivitas'),
                  isActive: _currentStep >= 3,
                  content: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Level Aktivitas',
                        border: OutlineInputBorder()),
                    value: _selectedActivity,
                    items: _activityLevels
                        .map((lvl) =>
                            DropdownMenuItem(value: lvl, child: Text(lvl)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedActivity = v!),
                  ),
                ),
                Step(
                  title: const Text('Tujuan'),
                  isActive: _currentStep >= 4,
                  content: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Tujuan Gizi', border: OutlineInputBorder()),
                    value: _selectedGoal,
                    items: _goals
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedGoal = v!),
                  ),
                ),
                Step(
                  title: const Text('Review'),
                  isActive: _currentStep >= 5,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Nama: ${_name.trim()}'),
                      Text('Gender: ${_isMale ? 'Laki-laki' : 'Perempuan'}'),
                      Text('Umur: $_age tahun'),
                      Text('Berat: ${_weight.round()} kg'),
                      Text('Tinggi: ${_height.round()} cm'),
                      Text('Aktivitas: $_selectedActivity'),
                      Text('Tujuan: $_selectedGoal'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepIcon(IconData icon, int step) {
    final done = _currentStep + 1 >= step;
    return Icon(icon, color: done ? _endColor : Colors.grey, size: 24);
  }
}

/// Clipper untuk lengkungan ke atas di tepian bawah header
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 40,
      size.width,
      size.height - 40,
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