// lib/screens/hasil/hasil_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:apk_gizi/data/models/food.dart';
import 'package:apk_gizi/data/models/activity.dart';
import 'package:apk_gizi/data/food_data.dart';
import 'package:apk_gizi/data/activity_data.dart';

class HasilScreen extends StatefulWidget {
  final double bmi;
  final String statusBmi;
  final String gender;
  final int age;
  final double weight;
  final double height;
  final String activity; // 'Rendah', 'Sedang', 'Tinggi'
  final String goal;     // 'Menurunkan Berat Badan', 'Menjaga Berat Badan', 'Meningkatkan Berat Badan'

  const HasilScreen({
    Key? key,
    required this.bmi,
    required this.statusBmi,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.activity,
    required this.goal,
  }) : super(key: key);

  @override
  State<HasilScreen> createState() => _HasilScreenState();
}

class _HasilScreenState extends State<HasilScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Food> _foods;
  late final List<Activity> _activities;

  static const _minC = 1200;

  @override
  void initState() {
    super.initState();
    final rng = Random(widget.bmi.hashCode);
    _foods = List<Food>.from(kFoods)..shuffle(rng);
    _activities = List<Activity>.from(kActivities)..shuffle(rng);

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _calcCalories() {
    final bmr = 10 * widget.weight +
        6.25 * widget.height -
        5 * widget.age +
        (widget.gender == 'Laki-laki' ? 5 : -161);
    final factor = {
      'Rendah': 1.2,
      'Sedang': 1.55,
      'Tinggi': 1.9,
    }[widget.activity]!;
    double total = bmr * factor;
    if (widget.goal == 'Menurunkan Berat Badan') total -= 500;
    if (widget.goal == 'Meningkatkan Berat Badan') total += 500;
    return total.clamp(_minC.toDouble(), double.infinity);
  }

  Map<String, double> _ratios() {
    switch (widget.goal) {
      case 'Meningkatkan Berat Badan':
        return {'c': .5, 'p': .25, 'f': .25};
      case 'Menurunkan Berat Badan':
        return {'c': .45, 'p': .3, 'f': .25};
      default:
        return {'c': .5, 'p': .2, 'f': .3};
    }
  }

  void _showActDetail(Activity act) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.25,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, ctl) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // title
              Text(
                act.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // icon row
              Row(
                children: [
                  _iconInfo(Icons.local_fire_department, '${act.caloriesBurned} kkal'),
                  _iconInfo(Icons.fitness_center, 'Intensitas ${act.intensity}'),
                ],
              ),
              const SizedBox(height: 16),

              // progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: act.intensity / 3,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.purple,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 16),

              // description
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    act.description,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Tutup'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.purple,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconInfo(IconData icon, String text) => Expanded(
    child: Row(
      children: [
        Icon(icon, color: Colors.purple),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final totalC = _calcCalories().round();
    final r = _ratios();
    final carb = (totalC * r['c']! / 4).round();
    final prot = (totalC * r['p']! / 4).round();
    final fat  = (totalC * r['f']! / 9).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Perhitungan'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummary(totalC),
            const SizedBox(height: 24),
            _buildMacros(carb, prot, fat, r),
            const SizedBox(height: 24),

            const Text(
              'Saran Makanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _foods.length,
                itemBuilder: (_, i) {
                  final f = _foods[i];
                  return AnimatedBuilder(
                    animation: _ctrl,
                    builder: (ctx, child) => FractionalTranslation(
                      translation: Offset(0, (1 - _ctrl.value) * 0.3),
                      child: Opacity(opacity: _ctrl.value, child: child),
                    ),
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Text('${f.calories} kkal', style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                f.description,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Saran Aktivitas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: _activities.map((act) {
                return AnimatedBuilder(
                  animation: _ctrl,
                  builder: (ctx, child) => FractionalTranslation(
                    translation: Offset(0, (1 - _ctrl.value) * 0.3),
                    child: Opacity(opacity: _ctrl.value, child: child),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 1,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade50,
                        child: Text(
                          '${act.caloriesBurned}',
                          style: const TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(act.name),
                      subtitle: Row(
                        children: List.generate(
                          act.intensity,
                          (_) => const Icon(Icons.star, size: 14, color: Colors.amber),
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showActDetail(act),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(int totalC) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 70,
            lineWidth: 8,
            percent: (widget.bmi / 40).clamp(0, 1),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.bmi.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(widget.statusBmi, style: const TextStyle(fontSize: 12)),
              ],
            ),
            progressColor: Colors.purple,
            backgroundColor: Colors.purple.shade100,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _info(Icons.calendar_today, '${widget.age} tahun'),
                _info(Icons.height, '${widget.height} cm'),
                _info(Icons.monitor_weight, '${widget.weight} kg'),
                _info(Icons.fitness_center, widget.activity),
                _info(Icons.flag, widget.goal),
              ],
            ),
          )
        ],
      ),
    ),
  );

  Widget _buildMacros(int carb, int prot, int fat, Map<String, double> r) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _macro('Karbo', carb, r['c']!),
          _macro('Protein', prot, r['p']!),
          _macro('Lemak', fat, r['f']!),
        ],
      ),
    ),
  );

  Widget _info(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, color: Colors.grey, size: 16),
      const SizedBox(width: 8),
      Text(text),
    ]),
  );

  Widget _macro(String label, int val, double percent) => Column(
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text('$val g'),
      Text('${(percent * 100).round()}%', style: const TextStyle(color: Colors.grey)),
    ],
  );
}
