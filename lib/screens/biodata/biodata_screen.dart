import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:apk_gizi/screens/hasil/hasil_screen.dart';
import 'package:apk_gizi/data/models/user_data.dart'; // Tambahkan impor ini

class BiodataScreen extends StatefulWidget {
  const BiodataScreen({super.key});
  @override
  State<BiodataScreen> createState() => _BiodataScreenState();
}

class _BiodataScreenState extends State<BiodataScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;

  // Step 0: nama individu
  final _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  // Step 1: gender
  bool _isMale = true;

  // Step 2: data
  int _age = 25;
  double _weight = 70;
  double _height = 170;

  // Step 3: aktivitas
  final List<String> _activityLevels = ['Rendah', 'Sedang', 'Tinggi'];
  final List<String> _activityDescriptions = [
    'Jarang olahraga (<2 jam/minggu)',
    'Aktivitas sedang (2-4 jam/minggu)',
    'Aktivitas tinggi (>4 jam/minggu)'
  ];
  final List<IconData> _activityIcons = [
    Icons.airline_seat_recline_normal,
    Icons.directions_walk,
    Icons.directions_run
  ];
  String _selectedActivity = 'Rendah';

  // Step 4: tujuan
  final List<String> _goals = [
    'Menurunkan Berat Badan',
    'Menjaga Berat Badan',
    'Meningkatkan Berat Badan'
  ];
  final List<IconData> _goalIcons = [
    Icons.trending_down,
    Icons.balance,
    Icons.trending_up
  ];
  final List<String> _goalDescriptions = [
    'Defisit kalori untuk penurunan berat badan yang sehat',
    'Menjaga berat badan ideal saat ini',
    'Surplus kalori untuk menambah massa tubuh'
  ];
  String _selectedGoal = 'Menjaga Berat Badan';

  // Kalkulasi
  double? _bmi;

  // Tip harian
  final List<String> _tips = [
    "Minum 8 gelas air setiap hari",
    "Konsumsi 5 porsi buah dan sayur setiap hari",
    "Kurangi konsumsi gula dan garam berlebih",
    "Pilih sumber protein sehat seperti ikan dan kacang-kacangan",
    "Tidur cukup 7-8 jam per hari",
    "Makan perlahan dan kenali rasa kenyang",
    "Batasi makanan olahan dan tinggi lemak jenuh"
  ];
  late String _todayTip;

  // Theme colors
  final Color _primaryColor = const Color(0xFF6200EE);
  final Color _secondaryColor = const Color(0xFFBB86FC);
  final Color _backgroundColor = const Color(0xFFF5F5F5);

  // Wave animation
  late final AnimationController _waveController;
  final PageController _pageController = PageController();

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
    _nameController.dispose();
    _nameFocus.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep == 0 && _nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Masukkan nama');
      return;
    }
    if (_currentStep < 5) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _calculateAndGo();
    }
  }

  Future<bool> _onPop() async {
    if (_pageController.page != _currentStep) {
      await _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return false;
    }
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return false;
    } else {
      if (context.canPop()) {
        context.pop();
        return true;
      } else {
        context.go('/home');
        return false;
      }
    }
  }

  void _back() {
    _onPop();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
        ),
      );
  }

  void _calculateAndGo() {
    setState(() => _bmi = null);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    Timer(const Duration(milliseconds: 1500), () {
      final h = _height / 100;
      final val = _weight / (h * h);
      setState(() => _bmi = double.parse(val.toStringAsFixed(1)));

      Navigator.of(context).pop();

      final userData = UserData(
        bmi: _bmi ?? 0.0,
        statusBmi: _bmiStatus,
        gender: _isMale ? 'Laki-laki' : 'Perempuan',
        age: _age,
        weight: _weight,
        height: _height,
        activity: _selectedActivity,
        goal: _selectedGoal,
      );
      context.push('/hasil', extra: userData);
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

    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _onPop();
      },
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        height: 40,
                        child: AnimatedBuilder(
                          animation: _waveController,
                          builder: (_, __) => CustomPaint(
                            painter: WavePainter(_waveController.value, Colors.white.withOpacity(0.9)),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Material(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _back,
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.arrow_back, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Kalkulator Gizi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _todayTip,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStepButton(Icons.person, 0, 'Profil'),
                        _buildStepButton(Icons.male, 1, 'Gender'),
                        _buildStepButton(Icons.straighten, 2, 'Ukuran'),
                        _buildStepButton(Icons.fitness_center, 3, 'Aktivitas'),
                        _buildStepButton(Icons.flag, 4, 'Tujuan'),
                        _buildStepButton(Icons.check_circle, 5, 'Review'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          builder: (context, val, _) => Container(
                            height: 6,
                            width: MediaQuery.of(context).size.width * val * 0.9,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_primaryColor, _secondaryColor],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildNameStep(),
                    _buildGenderStep(),
                    _buildMeasurementsStep(),
                    _buildActivityStep(),
                    _buildGoalStep(),
                    _buildReviewStep(),
                  ],
                ),
              ),

              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_currentStep > 0) ...[
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Kembali'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            side: BorderSide(color: Colors.grey.shade600),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _back,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          _currentStep == 5 ? Icons.check : Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        label: Text(
                          _currentStep == 5 ? 'Hitung' : 'Lanjut',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _next,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepButton(IconData icon, int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return GestureDetector(
      onTap: () {
        if (_currentStep > step) {
          setState(() => _currentStep = step);
          _pageController.animateToPage(
            step,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCurrent
                  ? _primaryColor
                  : isActive
                  ? _secondaryColor.withOpacity(0.7)
                  : Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey,
              size: 20,
            ),
          ),
          if (isCurrent)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label,
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Masukkan Nama Anda',
            style: TextStyle(
              color: _primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nama akan digunakan untuk personalisasi hasil',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            focusNode: _nameFocus,
            onTap: () => _nameFocus.requestFocus(),
            decoration: InputDecoration(
              labelText: 'Nama Lengkap',
              hintText: 'Contoh: Budi Santoso',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _next(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Data yang Anda masukkan akan digunakan untuk menghitung kebutuhan gizi harian.',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Gender Anda',
            style: TextStyle(
              color: _primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gender memengaruhi kebutuhan kalori dan nutrisi harian',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildGenderCard(
                  icon: Icons.male,
                  title: 'Laki-laki',
                  isSelected: _isMale,
                  color: Colors.blue,
                  onTap: () => setState(() => _isMale = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderCard(
                  icon: Icons.female,
                  title: 'Perempuan',
                  isSelected: !_isMale,
                  color: Colors.pink,
                  onTap: () => setState(() => _isMale = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber.shade800),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pria umumnya membutuhkan kalori lebih banyak dibandingkan wanita.',
                    style: TextStyle(color: Colors.amber.shade800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard({
    required IconData icon,
    required String title,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 50,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: color, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Dipilih',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Fisik Anda',
            style: TextStyle(
              color: _primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Diperlukan untuk menghitung BMI dan kebutuhan nutrisi',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          _buildMeasurementItem(
            title: 'Umur (tahun)',
            icon: Icons.calendar_today,
            value: _age.toString(),
            unit: 'tahun',
            color: Colors.purple,
            child: Slider(
              value: _age.toDouble(),
              min: 1,
              max: 120,
              divisions: 119,
              activeColor: _primaryColor,
              label: '$_age',
              onChanged: (v) => setState(() => _age = v.round()),
            ),
          ),
          _buildMeasurementItem(
            title: 'Tinggi Badan',
            icon: Icons.height,
            value: _height.round().toString(),
            unit: 'cm',
            color: Colors.blue,
            child: Slider(
              value: _height,
              min: 100,
              max: 220,
              divisions: 120,
              activeColor: _primaryColor,
              label: '${_height.round()}',
              onChanged: (v) => setState(() => _height = v),
            ),
          ),
          _buildMeasurementItem(
            title: 'Berat Badan',
            icon: Icons.monitor_weight_outlined,
            value: _weight.round().toString(),
            unit: 'kg',
            color: Colors.green,
            child: Slider(
              value: _weight,
              min: 20,
              max: 200,
              divisions: 180,
              activeColor: _primaryColor,
              label: '${_weight.round()}',
              onChanged: (v) => setState(() => _weight = v),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.teal.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Prediksi BMI',
                      style: TextStyle(
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Berdasarkan data yang Anda masukkan:',
                  style: TextStyle(color: Colors.teal.shade700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'BMI',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(_weight / (_height / 100 * _height / 100)).toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getBmiStatusText(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getBmiStatusColor(),
                              ),
                            ),
                          ],
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
    );
  }

  Color _getBmiStatusColor() {
    final bmi = _weight / (_height / 100 * _height / 100);
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBmiStatusText() {
    final bmi = _weight / (_height / 100 * _height / 100);
    if (bmi < 18.5) return 'Kurus';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obesitas';
  }

  Widget _buildMeasurementItem({
    required String title,
    required IconData icon,
    required String value,
    required String unit,
    required Color color,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Level Aktivitas',
            style: TextStyle(
              color: _primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seberapa aktif rutinitas harian Anda?',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            _activityLevels.length,
            (index) => _buildActivityCard(
              icon: _activityIcons[index],
              title: _activityLevels[index],
              description: _activityDescriptions[index],
              isSelected: _selectedActivity == _activityLevels[index],
              onTap: () => setState(() => _selectedActivity = _activityLevels[index]),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.orange.shade800),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Semakin tinggi level aktivitas, semakin banyak kalori yang dibutuhkan tubuh Anda.',
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? _primaryColor : Colors.grey.shade600,
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? _primaryColor : Colors.black87,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Radio(
          value: title,
          groupValue: _selectedActivity,
          activeColor: _primaryColor,
          onChanged: (value) {
            setState(() => _selectedActivity = value as String);
          },
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildGoalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tujuan Anda',
            style: TextStyle(
              color: _primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Apa yang ingin Anda capai dengan program gizi ini?',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            _goals.length,
            (index) => _buildGoalCard(
              icon: _goalIcons[index],
              title: _goals[index],
              description: _goalDescriptions[index],
              isSelected: _selectedGoal == _goals[index],
              onTap: () => setState(() => _selectedGoal = _goals[index]),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.green.shade800),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tujuan yang realistis adalah kunci keberhasilan program gizi.',
                    style: TextStyle(color: Colors.green.shade800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    Color goalColor = title.contains('Menurunkan')
        ? Colors.blue
        : title.contains('Menjaga')
        ? Colors.green
        : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? goalColor : Colors.grey.shade600,
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? goalColor : Colors.black87,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Radio(
          value: title,
          groupValue: _selectedGoal,
          activeColor: goalColor,
          onChanged: (value) {
            setState(() => _selectedGoal = value as String);
          },
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Data',
            style: TextStyle(
              color: _primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Periksa kembali data Anda sebelum menghitung',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildReviewItem(
                    icon: Icons.person,
                    title: 'Nama',
                    value: _nameController.text.isEmpty ? '-' : _nameController.text,
                    color: Colors.purple,
                  ),
                  const Divider(),
                  _buildReviewItem(
                    icon: _isMale ? Icons.male : Icons.female,
                    title: 'Gender',
                    value: _isMale ? 'Laki-laki' : 'Perempuan',
                    color: _isMale ? Colors.blue : Colors.pink,
                  ),
                  const Divider(),
                  _buildReviewItem(
                    icon: Icons.calendar_today,
                    title: 'Umur',
                    value: '$_age tahun',
                    color: Colors.orange,
                  ),
                  const Divider(),
                  _buildReviewItem(
                    icon: Icons.monitor_weight_outlined,
                    title: 'Berat Badan',
                    value: '${_weight.round()} kg',
                    color: Colors.green,
                  ),
                  const Divider(),
                  _buildReviewItem(
                    icon: Icons.height,
                    title: 'Tinggi Badan',
                    value: '${_height.round()} cm',
                    color: Colors.blue,
                  ),
                  const Divider(),
                  _buildReviewItem(
                    icon: _activityIcons[_activityLevels.indexOf(_selectedActivity)],
                    title: 'Level Aktivitas',
                    value: _selectedActivity,
                    color: Colors.purple,
                  ),
                  const Divider(),
                  _buildReviewItem(
                    icon: _goalIcons[_goals.indexOf(_selectedGoal)],
                    title: 'Tujuan',
                    value: _selectedGoal,
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.task_alt, color: Colors.indigo.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tekan "Hitung" untuk melihat hasil analisis gizi Anda.',
                    style: TextStyle(color: Colors.indigo.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animation;
  final Color color;

  WavePainter(this.animation, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = sin((x / size.width * 4 * pi) + (animation * 2 * pi)) * 10;
      path.lineTo(x, size.height * 0.8 + y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}