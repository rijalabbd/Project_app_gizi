/// Model untuk data aktivitas fisik
class Activity {
  final String name;
  final int caloriesBurned;
  final int intensity;    // 1 = ringan, 2 = sedang, 3 = tinggi
  final String description;

  /// Const constructor supaya bisa digunakan dalam const List
  const Activity({
    required this.name,
    required this.caloriesBurned,
    required this.intensity,
    required this.description,
  });
}
