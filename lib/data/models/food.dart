/// Model untuk data makanan
class Food {
  final String name;
  final int calories;
  final String description;

  /// Const constructor supaya bisa digunakan dalam const List
  const Food({
    required this.name,
    required this.calories,
    required this.description,
  });
}
