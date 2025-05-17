import 'package:apk_gizi/data/models/activity.dart';

/// Daftar aktivitas fisik (const) berdasarkan intensitas & tujuan
const List<Activity> kActivities = [
  // Menurunkan BB (aerobik moderat-tinggi)
  Activity(
    name: 'Jogging 30 menit',
    caloriesBurned: 250,
    intensity: 3,
    description: 'Lari santai 6 km/jam selama 30 menit di jalan datar.',
  ),
  Activity(
    name: 'Bersepeda Cepat 45 menit',
    caloriesBurned: 350,
    intensity: 3,
    description: 'Kayuh sepeda 15–20 km/jam di rute datar selama 45 menit.',
  ),
  Activity(
    name: 'Senam Aerobik 30 menit',
    caloriesBurned: 300,
    intensity: 2,
    description: 'Senam Zumba atau Poco-poco dengan gerakan penuh energi.',
  ),
  Activity(
    name: 'Berenang 30 menit',
    caloriesBurned: 300,
    intensity: 3,
    description: 'Gaya bebas di kolam renang, kecepatan sedang-tinggi.',
  ),
  Activity(
    name: 'Jalan Santai 30 menit',
    caloriesBurned: 120,
    intensity: 1,
    description: 'Jalan kaki santai 4 km/jam di taman atau komplek.',
  ),

  // Menjaga BB (moderate + strength)
  Activity(
    name: 'Jalan Cepat 30 menit',
    caloriesBurned: 180,
    intensity: 2,
    description: 'Jalan cepat 5 km/jam di rute datar atau ringan menanjak.',
  ),
  Activity(
    name: 'Bersepeda Santai 30 menit',
    caloriesBurned: 150,
    intensity: 2,
    description: 'Kayuh sepeda 10–12 km/jam di kompleks perumahan.',
  ),
  Activity(
    name: 'Senam Ringan 30 menit',
    caloriesBurned: 200,
    intensity: 2,
    description: 'Senam pagi dengan gerakan stretching dan penguatan ringan.',
  ),
  Activity(
    name: 'Push-up & Squat 15 menit',
    caloriesBurned: 160,
    intensity: 2,
    description: '3 set push-up & 3 set squat, total 15 menit tanpa istirahat lama.',
  ),
  Activity(
    name: 'Naik-Turun Tangga 20 menit',
    caloriesBurned: 180,
    intensity: 2,
    description: 'Naik turun tangga rumah atau gedung, tempo sedang.',
  ),

  // Meningkatkan BB (strength + cardio ringan)
  Activity(
    name: 'Latihan Beban 30 menit',
    caloriesBurned: 220,
    intensity: 2,
    description: 'Angkat beban dumbbell/barbel dengan repetisi sedang.',
  ),
  Activity(
    name: 'Push-up 3 set',
    caloriesBurned: 100,
    intensity: 2,
    description: '3 set push-up, masing-masing 8–12 ulang.',
  ),
  Activity(
    name: 'Sit-up 3 set',
    caloriesBurned: 80,
    intensity: 2,
    description: '3 set sit-up, masing-masing 12–15 ulang.',
  ),
  Activity(
    name: 'Squat 3 set',
    caloriesBurned: 120,
    intensity: 2,
    description: '3 set squat tubuh sendiri, masing-masing 12–15 ulang.',
  ),
  Activity(
    name: 'Jalan Santai 30 menit',
    caloriesBurned: 120,
    intensity: 1,
    description: 'Jalan santai untuk pemulihan, tempo sangat ringan.',
  ),

  // Tambahan – Menurunkan BB
  Activity(
    name: 'Berkebun 60 menit',
    caloriesBurned: 250,
    intensity: 2,
    description: 'Mencangkul, menanam, merapikan tanaman selama 1 jam.',
  ),
  Activity(
    name: 'Membersihkan Rumah 30 menit',
    caloriesBurned: 150,
    intensity: 2,
    description: 'Mengepel, menyapu, mengatur barang selama 30 menit.',
  ),

  // Tambahan – Menjaga BB
  Activity(
    name: 'Sepak Takraw Ringan 30 menit',
    caloriesBurned: 180,
    intensity: 2,
    description: 'Bermain ringkas, rally santai tanpa pukulan keras.',
  ),
  Activity(
    name: 'Badminton Santai 30 menit',
    caloriesBurned: 200,
    intensity: 2,
    description: 'Rally ringan, tempo sedang, fokus ke kelincahan.',
  ),

  // Tambahan – Meningkatkan BB
  Activity(
    name: 'Yoga Power 30 menit',
    caloriesBurned: 180,
    intensity: 2,
    description: 'Seri pose vinyasa yang menantang kekuatan otot.',
  ),
  Activity(
    name: 'Pilates 30 menit',
    caloriesBurned: 170,
    intensity: 2,
    description: 'Latihan core & fleksibilitas dengan alat ringkas.',
  ),
];
