import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = false;
  String _language = 'Bahasa Indonesia';

  // Mock user data
  final String _name = 'John Doe';
  final String _email = 'john.doe@example.com';
  final double _bmi = 22.5;
  final double _weight = 70;
  final int _avgCalories = 1800;

  // Mock weight history
  final List<FlSpot> _weightHistory = [
    FlSpot(0, 72),
    FlSpot(1, 71.5),
    FlSpot(2, 71),
    FlSpot(3, 70.5),
    FlSpot(4, 70),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header avatar & info
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade300, width: 4),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/user.png'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(child: Text(_name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            Center(child: Text(_email, style: const TextStyle(color: Colors.black54))),
            const SizedBox(height: 24),

            // Statistics cards
            Row(
              children: [
                _StatCard(label: 'BMI', value: _bmi.toStringAsFixed(1)),
                _StatCard(label: 'Berat', value: '$_weight kg'),
                _StatCard(label: 'Kalori', value: '$_avgCalories kkal'),
              ],
            ),
            const SizedBox(height: 24),

            // Customized weight chart
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  backgroundColor: Colors.white,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _weightHistory,
                      isCurved: true,
                      color: Colors.blue.shade600,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      curveSmoothness: 0.3,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade600.withOpacity(0.4),
                            Colors.blue.shade100.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Goals & activity
            ListTile(
              leading: Icon(Icons.flag, color: Colors.blue.shade600),
              title: const Text('Tujuan'),
              subtitle: const Text('Menurunkan Berat Badan'),
              trailing: TextButton(onPressed: () {}, child: const Text('Ubah')),
            ),
            ListTile(
              leading: Icon(Icons.fitness_center, color: Colors.blue.shade600),
              title: const Text('Aktivitas'),
              subtitle: const Text('Sedang'),
              trailing: TextButton(onPressed: () {}, child: const Text('Lihat')),
            ),
            const SizedBox(height: 24),

            // Quick actions
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _QuickAction(icon: Icons.edit, label: 'Edit Profil', onTap: () {}),
                _QuickAction(icon: Icons.lock, label: 'Ubah Password', onTap: () {}),
                _QuickAction(icon: Icons.notifications, label: 'Notifikasi', onTap: () {}),
                _QuickAction(icon: Icons.logout, label: 'Keluar', onTap: () {}),
              ],
            ),
            const SizedBox(height: 24),

            // Settings
            SwitchListTile(
              title: const Text('Mode Gelap'),
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            ListTile(
              title: const Text('Bahasa'),
              trailing: DropdownButton<String>(
                value: _language,
                items: const [
                  DropdownMenuItem(value: 'Bahasa Indonesia', child: Text('Indonesia')),
                  DropdownMenuItem(value: 'English', child: Text('English')),
                ],
                onChanged: (v) => setState(() => _language = v!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.blue.shade100.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({Key? key, required this.icon, required this.label, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue.shade600),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
