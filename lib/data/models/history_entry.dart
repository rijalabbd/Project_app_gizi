// lib/data/models/history_entry.dart
class HistoryEntry {
  final DateTime date;
  final int calories;
  final int carb;
  final int protein;
  final int fat;

  HistoryEntry({
    required this.date,
    required this.calories,
    required this.carb,
    required this.protein,
    required this.fat,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'calories': calories,
    'carb': carb,
    'protein': protein,
    'fat': fat,
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      date: DateTime.parse(json['date'] as String),
      calories: json['calories'] as int,
      carb: json['carb'] as int,
      protein: json['protein'] as int,
      fat: json['fat'] as int,
    );
  }
}
