/// Model untuk data aktivitas fisik dengan detail tambahan
class Activity {
  final String name;
  final int caloriesBurned;
  final int intensity;    // 1 = ringan, 2 = sedang, 3 = tinggi
  final String description;

  // Tambahan fields:
  final String duration;             // Contoh: "30 menit"
  final List<String> equipment;      // Contoh: ["Sepatu Lari"]
  final List<String> muscleGroups;   // Contoh: ["Kaki", "Jantung"]
  final String category;             // Contoh: "Cardio"
  final String? referenceUrl;        // URL referensi (opsional)

  /// Const constructor supaya bisa digunakan dalam const List
  const Activity({
    required this.name,
    required this.caloriesBurned,
    required this.intensity,
    required this.description,
    this.duration = '',
    this.equipment = const [],
    this.muscleGroups = const [],
    this.category = '',
    this.referenceUrl,              // Ditambahkan untuk referensi
  });
}