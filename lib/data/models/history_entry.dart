import 'dart:convert';

class HistoryEntry {
  final int calories;
  final int carb;
  final int protein;
  final int fat;
  final DateTime date;

  HistoryEntry({
    required this.calories,
    required this.carb,
    required this.protein,
    required this.fat,
    required this.date,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      calories: json['calories'] as int,
      carb: json['carb'] as int,
      protein: json['protein'] as int,
      fat: json['fat'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'carb': carb,
      'protein': protein,
      'fat': fat,
      'date': date.toIso8601String(),
    };
  }
}